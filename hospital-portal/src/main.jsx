import React, { useEffect, useRef, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Html5Qrcode } from 'html5-qrcode';
import {
  Shield,
  Search,
  User,
  HeartPulse,
  LogOut,
  Clock,
  Camera,
  FileText,
  AlertTriangle,
  Activity,
  ClipboardList,
  RefreshCw,
  Plus,
  ActivitySquare,
  LayoutDashboard,
  Building2,
  Users,
  Settings,
  Database
} from 'lucide-react';
import './styles.css';

const API = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

const request = async (path, options = {}, token) => {
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
  const response = await fetch(`${API}${path}`, {
    ...options,
    headers: { ...headers, ...options.headers },
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.detail || 'Request failed');
  return data;
};

// ─────────────────────────────────────────────────────────────
// WEBCAM QR SCANNER COMPONENT (Universal html5-qrcode implementation)
// ─────────────────────────────────────────────────────────────
function Scanner({ onResult, onClose }) {
  const qrRegionId = 'html5qr-code-region';
  const scannerRef = useRef(null);
  const [error, setError] = useState('');

  useEffect(() => {
    const html5QrCode = new Html5Qrcode(qrRegionId);
    scannerRef.current = html5QrCode;

    html5QrCode
      .start(
        { facingMode: 'environment' },
        {
          fps: 10,
          qrbox: (width, height) => {
            const size = Math.min(width, height) * 0.7;
            return { width: size, height: size };
          },
        },
        (decodedText) => {
          onResult(decodedText);
          if (html5QrCode.isScanning) {
            html5QrCode.stop().then(() => onClose()).catch(() => onClose());
          }
        },
        () => {
          // Frame match errors are normal during scanning, ignore them
        }
      )
      .catch((err) => {
        console.error('Camera initialization error:', err);
        setError('Could not access camera. Please check browser permissions.');
      });

    return () => {
      if (html5QrCode.isScanning) {
        html5QrCode.stop().catch((err) => console.error('Stop error:', err));
      }
    };
  }, [onResult, onClose]);

  return (
    <div className="modal">
      <div className="modalCard">
        <button className="close" onClick={onClose}>×</button>
        <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <Camera size={24} style={{ color: 'var(--accent-green)' }} />
          Scan Patient QR Code
        </h2>
        <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
          Position the patient's QR code inside the camera target frame.
        </p>
        
        {error ? (
          <div className="error" style={{ margin: '12px 0' }}>
            <AlertTriangle size={18} />
            {error}
          </div>
        ) : (
          <div className="camera-container" style={{ margin: '16px 0' }}>
            <div id={qrRegionId} style={{ width: '100%' }}></div>
            <div className="scanner-laser"></div>
          </div>
        )}
        
        <button className="secondary" onClick={onClose}>
          Cancel Scan
        </button>
      </div>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// LOGIN COMPONENT
// ─────────────────────────────────────────────────────────────
function Login({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const submit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      const data = await request('/auth/login', {
        method: 'POST',
        body: JSON.stringify({ email, password }),
      });
      if (data.user?.role !== 'hospital_staff' && data.user?.role !== 'admin') {
        throw new Error('This portal is restricted to authorized hospital or admin staff.');
      }
      onLogin(data);
    } catch (e) {
      setError(e.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="login">
      <section className="loginInfo">
        <span className="badge">
          <Shield size={12} style={{ marginRight: '4px' }} />
          LifePass
        </span>
        <h1>Health Identity Portal</h1>
        <p>
          Centralized secure access for hospital clinicians and system administrators.
        </p>
      </section>

      <form onSubmit={submit} className="loginCard">
        <h2>Authorized Login</h2>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '8px' }}>
          Sign in using your clinical or admin credentials.
        </p>

        <label>
          Email Address
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="staff@hospital.org"
            required
          />
        </label>

        <label>
          Security Password
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
          />
        </label>

        {error && (
          <div className="error">
            <AlertTriangle size={18} />
            {error}
          </div>
        )}

        <button className="primary" disabled={loading} style={{ width: '100%', marginTop: '8px' }}>
          {loading ? 'Authenticating...' : 'Sign In Securely'}
        </button>
      </form>
    </main>
  );
}

// ─────────────────────────────────────────────────────────────
// SHARED UI COMPONENTS
// ─────────────────────────────────────────────────────────────
function InfoTile({ title, value, danger, fullWidth, icon: Icon }) {
  return (
    <article className={`info-tile ${danger ? 'alert' : ''} ${fullWidth ? 'full-width' : ''}`}>
      <h3>
        {Icon && <Icon size={14} />}
        {title}
      </h3>
      <p>{value}</p>
    </article>
  );
}

function PatientProfileView({ patient, onNote }) {
  const diseases = (patient.chronic_diseases || []).join(', ') || 'No chronic conditions recorded';
  const allergiesList = (patient.allergies || []).map((x) => typeof x === 'string' ? x : `${x.allergy} (${x.severity})`);
  const allergies = allergiesList.join(', ') || 'No allergies recorded';
  
  const meds = typeof patient.current_medications === 'string' 
      ? patient.current_medications
      : (patient.current_medications || [])
      .map((x) => `${x.name} — ${x.dosage} (${x.frequency})`)
      .join('\n') || 'No active medications recorded';

  return (
    <section className="profile card">
      <div className="profileHead">
        <div>
          <span className="eyebrow">Emergency profile</span>
          <h2>{patient.patient_name}</h2>
          <p style={{ display: 'flex', alignItems: 'center', gap: '6px', marginTop: '4px' }}>
            <User size={14} />
            Patient ID: #{patient.patient_id}
          </p>
        </div>
        <span className={`risk ${patient.risk_level || 'unknown'}`}>
          <span className="dot" style={{
            width: '6px',
            height: '6px',
            borderRadius: '50%',
            backgroundColor: 'currentColor'
          }}></span>
          {patient.risk_level ? `${patient.risk_level} risk` : 'Risk level unavailable'}
        </span>
      </div>

      <div className="profile-grid">
        <InfoTile
          title="Blood Group"
          value={patient.blood_group || 'Not recorded'}
          danger={patient.blood_group === 'O-' || patient.blood_group === 'AB-'}
          icon={HeartPulse}
        />
        <InfoTile
          title="Emergency Contact"
          value={`${patient.emergency_contact || 'None'}\n${patient.emergency_contact_phone || 'None'}`}
          icon={User}
        />
        <InfoTile
          title="Chronic Conditions"
          value={diseases}
          icon={ClipboardList}
        />
        <InfoTile
          title="Allergies & Severities"
          value={allergies}
          danger={(patient.allergies || []).some((x) => x.severity === 'severe')}
          icon={AlertTriangle}
        />
        <InfoTile
          title="Current Medications"
          value={meds}
          icon={FileText}
        />
        <InfoTile
          title="AI Emergency Summary"
          value={patient.ai_summary || 'No AI summary generated for this patient.'}
          fullWidth
          icon={Activity}
        />
      </div>

      <button className="primary" onClick={onNote} style={{ alignSelf: 'start', marginTop: '8px' }}>
        <Plus size={18} />
        Add Emergency Treatment Note
      </button>
    </section>
  );
}

// ─────────────────────────────────────────────────────────────
// LAYOUT COMPONENT (Responsive Sidebar / Bottom Nav)
// ─────────────────────────────────────────────────────────────
function Layout({ session, onLogout, navItems, activeTab, setActiveTab, children }) {
  return (
    <div className="layout">
      {/* Sidebar / Bottom Nav */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <h1>
            <Shield size={20} style={{ color: 'var(--accent-green)' }} />
            LifePass
          </h1>
          <span style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>
            {session.user.role === 'admin' ? 'Admin Portal' : 'Hospital Portal'}
          </span>
        </div>

        <nav className="nav-menu">
          {navItems.map((item) => (
            <button
              key={item.id}
              className={`nav-item ${activeTab === item.id ? 'active' : ''}`}
              onClick={() => setActiveTab(item.id)}
            >
              <item.icon size={20} />
              <span>{item.label}</span>
            </button>
          ))}
        </nav>

        <div className="sidebar-footer">
          <div className="user-profile">
            <div className="user-profile-icon">
              <User size={18} />
            </div>
            <div className="user-profile-info">
              <span className="user-profile-name">{session.user.name}</span>
              <span className="user-profile-role">{session.user.role.replace('_', ' ')}</span>
            </div>
          </div>
          <button className="secondary" onClick={onLogout} style={{ width: '100%', fontSize: '0.85rem' }}>
            <LogOut size={16} />
            Sign Out
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="main-content">
        <header className="top-header">
          <h2>{navItems.find(i => i.id === activeTab)?.label}</h2>
        </header>
        <div className="content-wrapper">
          {children}
        </div>
      </main>
    </div>
  );
}

// ─────────────────────────────────────────────────────────────
// ADMIN PORTAL
// ─────────────────────────────────────────────────────────────
function AdminPortal({ session, onLogout }) {
  const [activeTab, setActiveTab] = useState('dashboard');
  
  const [stats, setStats] = useState({ total_hospitals: 0, total_patients: 0, active_emergencies: 0 });
  const [hospitals, setHospitals] = useState([]);
  const [patients, setPatients] = useState([]);
  const [logs, setLogs] = useState([]);

  const [registerModal, setRegisterModal] = useState(false);
  const [regName, setRegName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPhone, setRegPhone] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regLoading, setRegLoading] = useState(false);

  const handleRegister = async (e) => {
    e.preventDefault();
    setRegLoading(true);
    try {
      await request('/auth/register', {
        method: 'POST',
        body: JSON.stringify({
          name: regName,
          email: regEmail,
          phone: regPhone,
          password: regPassword,
          role: 'hospital_staff'
        })
      });
      alert('Hospital registered successfully!');
      setRegisterModal(false);
      setRegName(''); setRegEmail(''); setRegPhone(''); setRegPassword('');
      const res = await request('/admin/hospitals', {}, session.access_token);
      setHospitals(res);
    } catch (err) {
      alert(err.message || 'Registration failed');
    } finally {
      setRegLoading(false);
    }
  };

  useEffect(() => {
    const fetchData = async () => {
      try {
        if (activeTab === 'dashboard') {
          const res = await request('/admin/stats', {}, session.access_token);
          setStats(res);
        } else if (activeTab === 'hospitals') {
          const res = await request('/admin/hospitals', {}, session.access_token);
          setHospitals(res);
        } else if (activeTab === 'patients') {
          const res = await request('/admin/patients', {}, session.access_token);
          setPatients(res);
        } else if (activeTab === 'logs') {
          const res = await request('/admin/logs', {}, session.access_token);
          setLogs(res);
        }
      } catch (e) {
        console.error('Failed to fetch admin data:', e);
      }
    };
    fetchData();
  }, [activeTab, session.access_token]);

  const navItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'hospitals', label: 'Hospitals', icon: Building2 },
    { id: 'patients', label: 'Patients', icon: Users },
    { id: 'logs', label: 'System Logs', icon: Database },
    { id: 'settings', label: 'Settings', icon: Settings },
  ];

  return (
    <Layout session={session} onLogout={onLogout} navItems={navItems} activeTab={activeTab} setActiveTab={setActiveTab}>
      {activeTab === 'dashboard' && (
        <div>
          <div className="stats-grid">
            <div className="stat-card">
              <div className="stat-icon"><Building2 size={24} /></div>
              <div className="stat-value">{stats.total_hospitals}</div>
              <div className="stat-label">Registered Hospitals</div>
            </div>
            <div className="stat-card">
              <div className="stat-icon"><Users size={24} /></div>
              <div className="stat-value">{stats.total_patients}</div>
              <div className="stat-label">Total Patients</div>
            </div>
            <div className="stat-card">
              <div className="stat-icon"><Activity size={24} /></div>
              <div className="stat-value">{stats.active_emergencies}</div>
              <div className="stat-label">System Audit Logs (24h)</div>
            </div>
          </div>
          <div className="card">
            <h3 style={{ marginBottom: '16px' }}>System Health</h3>
            <p style={{ color: 'var(--text-secondary)' }}>All systems operational. The OCR and AI microservices are online.</p>
          </div>
        </div>
      )}

      {activeTab === 'hospitals' && (
        <div style={{ display: 'grid', gap: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'flex-end' }}>
            <button className="primary" onClick={() => setRegisterModal(true)}>
              <Plus size={16} /> Register New Hospital
            </button>
          </div>
          <div className="table-container">
            <table>
            <thead>
              <tr>
                <th>Hospital ID</th>
                <th>Name</th>
                <th>Email</th>
                <th>Registered On</th>
              </tr>
            </thead>
            <tbody>
              {hospitals.map(h => (
                <tr key={h.id}>
                  <td>#{h.id}</td>
                  <td style={{ fontWeight: 600 }}>{h.name}</td>
                  <td>{h.email}</td>
                  <td>{new Date(h.created_at).toLocaleDateString()}</td>
                </tr>
              ))}
              {hospitals.length === 0 && (
                <tr><td colSpan="4" style={{ textAlign: 'center', padding: '32px', color: 'var(--text-muted)' }}>No hospitals registered yet.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        </div>
      )}

      {activeTab === 'patients' && (
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Patient ID</th>
                <th>Name</th>
                <th>Blood Group</th>
                <th>Risk Level</th>
              </tr>
            </thead>
            <tbody>
              {patients.map(p => (
                <tr key={p.id}>
                  <td>#{p.patient_id}</td>
                  <td style={{ fontWeight: 600 }}>{p.name}</td>
                  <td>{p.blood_group}</td>
                  <td><span className={`badge ${p.risk_level === 'High' ? 'danger' : ''}`}>{p.risk_level}</span></td>
                </tr>
              ))}
              {patients.length === 0 && (
                <tr><td colSpan="4" style={{ textAlign: 'center', padding: '32px', color: 'var(--text-muted)' }}>No patients registered yet.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {activeTab === 'logs' && (
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Timestamp</th>
                <th>Action</th>
                <th>Doctor ID</th>
                <th>Patient ID</th>
                <th>IP Address</th>
              </tr>
            </thead>
            <tbody>
              {logs.map(log => (
                <tr key={log.id}>
                  <td>{new Date(log.time).toLocaleString()}</td>
                  <td style={{ textTransform: 'capitalize', color: 'var(--accent-green)' }}>{log.action.replaceAll('_', ' ')}</td>
                  <td>#{log.doctor_id}</td>
                  <td>#{log.patient_id}</td>
                  <td style={{ color: 'var(--text-muted)' }}>{log.ip_address || 'N/A'}</td>
                </tr>
              ))}
              {logs.length === 0 && (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '32px', color: 'var(--text-muted)' }}>No system logs recorded.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {activeTab === 'settings' && (
        <div className="card">
          <h3>Platform Settings</h3>
          <p style={{ color: 'var(--text-secondary)', marginTop: '8px' }}>Global configurations can be updated here.</p>
        </div>
      )}

      {registerModal && (
        <div className="modal">
          <form className="modalCard" onSubmit={handleRegister}>
            <button type="button" className="close" onClick={() => setRegisterModal(false)}>×</button>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Building2 size={22} style={{ color: 'var(--accent-green)' }} />
              Register New Hospital
            </h2>
            <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
              Create an authorized account for a new hospital facility.
            </p>

            <label>
              Hospital / Clinic Name
              <input value={regName} onChange={e => setRegName(e.target.value)} required />
            </label>
            <label>
              Contact Email
              <input type="email" value={regEmail} onChange={e => setRegEmail(e.target.value)} required />
            </label>
            <label>
              Phone Number
              <input value={regPhone} onChange={e => setRegPhone(e.target.value)} required />
            </label>
            <label>
              Initial Password
              <input type="password" value={regPassword} onChange={e => setRegPassword(e.target.value)} required minLength={6} />
            </label>

            <button className="primary" disabled={regLoading} style={{ marginTop: '12px' }}>
              {regLoading ? 'Registering...' : 'Register Hospital'}
            </button>
          </form>
        </div>
      )}
    </Layout>
  );
}

// ─────────────────────────────────────────────────────────────
// HOSPITAL PORTAL
// ─────────────────────────────────────────────────────────────
function HospitalPortal({ session, onLogout }) {
  const [activeTab, setActiveTab] = useState('scan');
  
  const [query, setQuery] = useState('');
  const [patient, setPatient] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const [scan, setScan] = useState(false);
  const [noteModal, setNoteModal] = useState(false);
  const [notes, setNotes] = useState('');
  const [meds, setMeds] = useState('');
  const [activity, setActivity] = useState([]);

  const lookup = async (input) => {
    const value = (input ?? query).trim();
    if (!value) return;
    setLoading(true);
    setError('');
    try {
      let id = value;
      // If the input is not a plain numeric ID, treat it as an encrypted token
      if (!/^\d+$/.test(value)) {
        const qr = await request(
          '/qr/scan',
          {
            method: 'POST',
            body: JSON.stringify({ encrypted_token: value }),
          },
          session.access_token
        );
        id = qr.patient_id;
        // The QR code backend route automatically invalidates the QR now!
        alert(qr.message); 
      }
      const data = await request(`/hospital/patient/${id}`, {}, session.access_token);
      setPatient(data);
      setQuery(value);
    } catch (e) {
      setPatient(null);
      setError(e.message || 'Patient profile not found.');
    } finally {
      setLoading(false);
    }
  };

  const saveNote = async (e) => {
    e.preventDefault();
    try {
      const medicationsArray = meds
        .split(',')
        .map((x) => x.trim())
        .filter(Boolean);

      await request(
        '/hospital/treatment',
        {
          method: 'POST',
          body: JSON.stringify({
            patient_id: patient.patient_id,
            notes,
            medications: medicationsArray,
          }),
        },
        session.access_token
      );
      setNoteModal(false);
      setNotes('');
      setMeds('');
      alert('Treatment record successfully saved.');
    } catch (e) {
      alert(e.message || 'Failed to save treatment record.');
    }
  };

  const showActivity = async () => {
    try {
      const data = await request('/hospital/my-activity', {}, session.access_token);
      setActivity(data.activity || []);
    } catch (e) {
      setError(e.message || 'Failed to fetch clinical logs.');
    }
  };

  useEffect(() => {
    if (activeTab === 'history') showActivity();
  }, [activeTab]);

  const navItems = [
    { id: 'scan', label: 'Emergency Access', icon: Camera },
    { id: 'history', label: 'My Activity', icon: Clock },
    { id: 'settings', label: 'Settings', icon: Settings },
  ];

  return (
    <Layout session={session} onLogout={onLogout} navItems={navItems} activeTab={activeTab} setActiveTab={setActiveTab}>
      {activeTab === 'scan' && (
        <div style={{ display: 'grid', gap: '24px' }}>
          <section className="lookup card">
            <span className="eyebrow">Patient Search</span>
            <h2>Access Patient Profile</h2>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
              Scan the patient's single-use emergency QR code, or search by their Patient ID.
            </p>

            <div className="search-box">
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                onKeyDown={(e) => e.key === 'Enter' && lookup()}
                placeholder="Patient ID or Encrypted Token"
              />
              <button className="primary" onClick={() => lookup()} disabled={loading}>
                <Search size={16} />
                {loading ? 'Fetching…' : 'Search'}
              </button>
            </div>

            <button className="secondary" onClick={() => setScan(true)} style={{ marginTop: '4px' }}>
              <Camera size={16} />
              Use Device Camera
            </button>

            {error && (
              <div className="error">
                <AlertTriangle size={18} />
                {error}
              </div>
            )}
          </section>

          {patient ? (
            <PatientProfileView patient={patient} onNote={() => setNoteModal(true)} />
          ) : (
            <div className="card" style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              padding: '60px 20px',
              color: 'var(--text-secondary)',
              textAlign: 'center'
            }}>
              <ActivitySquare size={48} style={{ color: 'var(--border-color)', marginBottom: '16px' }} />
              <h3>No Patient Profile Loaded</h3>
              <p style={{ maxWidth: '320px', fontSize: '0.9rem', marginTop: '8px' }}>
                Perform a search or scan a QR code to retrieve a patient's critical emergency record.
              </p>
            </div>
          )}
        </div>
      )}

      {activeTab === 'history' && (
        <section className="activity card">
          <div className="activity-header">
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <Clock size={20} style={{ color: 'var(--accent-green)' }} />
              Recent Retrievals & Treatments
            </h2>
            <button className="secondary" onClick={showActivity} style={{ padding: '6px 12px', fontSize: '0.8rem' }}>
              <RefreshCw size={14} />
              Refresh Logs
            </button>
          </div>

          {activity.length === 0 ? (
            <p style={{ color: 'var(--text-secondary)', fontStyle: 'italic', padding: '20px 0' }}>No patient retrievals recorded in this session.</p>
          ) : (
            <ul>
              {activity.map((x, i) => (
                <li key={i}>
                  <div className="desc">
                    <User size={16} style={{ color: 'var(--text-secondary)' }} />
                    <div>
                      <strong style={{ textTransform: 'capitalize' }}>
                        {x.action.replaceAll('_', ' ')}
                      </strong>
                      <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginLeft: '8px' }}>
                        (Patient ID: #{x.patient_id})
                      </span>
                    </div>
                  </div>
                  <span className="time">{new Date(x.timestamp).toLocaleString()}</span>
                </li>
              ))}
            </ul>
          )}
        </section>
      )}

      {activeTab === 'settings' && (
        <div className="card">
          <h3>Account Settings</h3>
          <p style={{ color: 'var(--text-secondary)', marginTop: '8px' }}>Configure your portal preferences.</p>
        </div>
      )}

      {scan && <Scanner onResult={(v) => lookup(v)} onClose={() => setScan(false)} />}

      {noteModal && (
        <div className="modal">
          <form className="modalCard" onSubmit={saveNote}>
            <button type="button" className="close" onClick={() => setNoteModal(false)}>×</button>
            <h2 style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
              <ClipboardList size={22} style={{ color: 'var(--accent-green)' }} />
              Add Treatment Record
            </h2>
            <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
              Log notes and medications administered to patient #{patient.patient_id}.
            </p>

            <label>
              Clinical Treatment Notes
              <textarea
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Enter details of symptoms, diagnosis, and interventions..."
                required
              />
            </label>

            <label>
              Administered Medications (Comma-separated)
              <input
                value={meds}
                onChange={(e) => setMeds(e.target.value)}
                placeholder="e.g. Paracetamol 500mg, Amoxicillin 250mg"
              />
            </label>

            <button className="primary" style={{ marginTop: '12px' }}>
              Save Treatment Record
            </button>
          </form>
        </div>
      )}
    </Layout>
  );
}

// ─────────────────────────────────────────────────────────────
// APP ROOT ROUTER
// ─────────────────────────────────────────────────────────────
function App() {
  const [session, setSession] = useState(() =>
    JSON.parse(localStorage.getItem('portal-session') || 'null')
  );

  const login = (s) => {
    localStorage.setItem('portal-session', JSON.stringify(s));
    setSession(s);
  };

  const logout = () => {
    localStorage.removeItem('portal-session');
    setSession(null);
  };

  if (!session) {
    return <Login onLogin={login} />;
  }

  // Role-based routing
  if (session.user.role === 'admin') {
    return <AdminPortal session={session} onLogout={logout} />;
  }
  
  if (session.user.role === 'hospital_staff') {
    return <HospitalPortal session={session} onLogout={logout} />;
  }

  // Fallback (should not happen based on Login component filter)
  return <div>Unauthorized access.</div>;
}

createRoot(document.getElementById('root')).render(<App />);
