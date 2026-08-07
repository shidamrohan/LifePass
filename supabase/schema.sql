-- Enable the "uuid-ossp" extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Profiles Table (Patients & Hospital Staff)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('patient', 'hospital_staff', 'admin')),
    phone TEXT,
    dob DATE,
    gender TEXT,
    blood_group TEXT,
    height NUMERIC,
    weight NUMERIC,
    emergency_contact TEXT,
    emergency_contact_phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own profile
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Create a function to safely get user role without triggering RLS
CREATE OR REPLACE FUNCTION public.get_auth_role()
RETURNS text AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER;

-- Allow hospital staff to read any patient profile
CREATE POLICY "Hospital staff can view patient profiles" ON profiles
    FOR SELECT USING (
        public.get_auth_role() IN ('hospital_staff', 'admin')
    );

-- 2. Diseases Table
CREATE TABLE diseases (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    disease_name TEXT NOT NULL,
    diagnosed_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE diseases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Patients view own diseases" ON diseases FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Patients insert own diseases" ON diseases FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Patients delete own diseases" ON diseases FOR DELETE USING (auth.uid() = patient_id);
CREATE POLICY "Staff view all diseases" ON diseases FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));

-- 3. Allergies Table
CREATE TABLE allergies (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    allergy TEXT NOT NULL,
    severity TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE allergies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Patients view own allergies" ON allergies FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Patients insert own allergies" ON allergies FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Patients delete own allergies" ON allergies FOR DELETE USING (auth.uid() = patient_id);
CREATE POLICY "Staff view all allergies" ON allergies FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));

-- 4. Medicines Table
CREATE TABLE medicines (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    medicine TEXT NOT NULL,
    dosage TEXT,
    frequency TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE medicines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Patients view own medicines" ON medicines FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Patients insert own medicines" ON medicines FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Patients delete own medicines" ON medicines FOR DELETE USING (auth.uid() = patient_id);
CREATE POLICY "Staff view all medicines" ON medicines FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));

-- 5. Medical Reports Table
CREATE TABLE medical_reports (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    report_type TEXT NOT NULL,
    file_url TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE medical_reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Patients view own reports" ON medical_reports FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Patients insert own reports" ON medical_reports FOR INSERT WITH CHECK (auth.uid() = patient_id);
CREATE POLICY "Staff view all reports" ON medical_reports FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));

-- 6. AI Summary Table
CREATE TABLE ai_summary (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    summary TEXT NOT NULL,
    risk_level TEXT,
    generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE ai_summary ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Patients view own summaries" ON ai_summary FOR SELECT USING (auth.uid() = patient_id);
CREATE POLICY "Staff view all summaries" ON ai_summary FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));
-- (FastAPI will insert using service_role, bypassing RLS)

-- 7. Audit Logs Table
CREATE TABLE audit_logs (
    id SERIAL PRIMARY KEY,
    doctor_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address TEXT
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Staff insert audit logs" ON audit_logs FOR INSERT WITH CHECK (public.get_auth_role() IN ('hospital_staff', 'admin'));
CREATE POLICY "Staff view own audit logs" ON audit_logs FOR SELECT USING (doctor_id = auth.uid());
CREATE POLICY "Admin view audit logs" ON audit_logs FOR SELECT USING (public.get_auth_role() = 'admin');

-- Trigger to create a profile automatically when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Unknown User'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'patient')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 8. QR Codes Table (for emergency scanning)
CREATE TABLE qr_codes (
    id SERIAL PRIMARY KEY,
    patient_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL UNIQUE,
    encrypted_token TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for qr_codes
ALTER TABLE qr_codes ENABLE ROW LEVEL SECURITY;

-- Allow patients to generate their own QR codes
CREATE POLICY "Patients insert own qr_codes" ON qr_codes FOR INSERT WITH CHECK (auth.uid() = patient_id);
-- Allow patients to view their own QR codes
CREATE POLICY "Patients view own qr_codes" ON qr_codes FOR SELECT USING (auth.uid() = patient_id);
-- Allow patients to delete their own QR codes (for regenerating)
CREATE POLICY "Patients delete own qr_codes" ON qr_codes FOR DELETE USING (auth.uid() = patient_id);
-- Allow staff to scan (view) QR codes
CREATE POLICY "Staff view qr_codes" ON qr_codes FOR SELECT USING (public.get_auth_role() IN ('hospital_staff', 'admin'));
-- Allow staff to consume (delete) QR codes
CREATE POLICY "Staff delete qr_codes" ON qr_codes FOR DELETE USING (public.get_auth_role() IN ('hospital_staff', 'admin'));

-- Add details column to audit_logs
ALTER TABLE audit_logs ADD COLUMN details JSONB;
