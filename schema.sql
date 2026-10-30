-- =============================================================================
-- Comprehensive School Management System (SMS) Database Schema
-- Compatible with PostgreSQL 13+ (ANSI SQL compliant)
-- =============================================================================

-- Enable UUID extension if supported
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- 1. SETTINGS, ACADEMIC CALENDAR & USER PERMISSIONS (RBAC)
-- =============================================================================

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,       -- e.g., 'Super Admin', 'Admin', 'Teacher', 'Student', 'Parent', 'Accountant'
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id SERIAL PRIMARY KEY,
    module VARCHAR(50) NOT NULL,            -- e.g., 'students', 'fees', 'attendance'
    action VARCHAR(50) NOT NULL,            -- e.g., 'create', 'read', 'update', 'delete', 'export'
    slug VARCHAR(100) NOT NULL UNIQUE,      -- e.g., 'students.create'
    description TEXT
);

CREATE TABLE role_permissions (
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INT NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    role_id INT NOT NULL REFERENCES roles(id),
    username VARCHAR(60) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(30) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    avatar_url VARCHAR(255),
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE academic_years (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,       -- e.g., '2026-2027'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE academic_terms (
    id SERIAL PRIMARY KEY,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,              -- e.g., 'Term 1', 'Semester 1'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE
);

CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    school_name VARCHAR(150) NOT NULL,
    school_code VARCHAR(30) UNIQUE NOT NULL,
    tagline VARCHAR(200),
    email VARCHAR(100),
    phone VARCHAR(30),
    address TEXT,
    logo_url VARCHAR(255),
    currency_code VARCHAR(10) DEFAULT 'USD',
    currency_symbol VARCHAR(10) DEFAULT '$',
    timezone VARCHAR(50) DEFAULT 'UTC',
    date_format VARCHAR(20) DEFAULT 'YYYY-MM-DD',
    current_academic_year_id INT REFERENCES academic_years(id),
    config_json JSONB DEFAULT '{}',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 2. TEACHERS & STAFF
-- =============================================================================

CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,      -- e.g., 'Science', 'Mathematics', 'Administration'
    code VARCHAR(20) UNIQUE
);

CREATE TABLE designations (
    id SERIAL PRIMARY KEY,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    title VARCHAR(100) NOT NULL             -- e.g., 'Senior Teacher', 'Lab Assistant', 'Head of Department'
);

CREATE TABLE staff (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    staff_code VARCHAR(30) UNIQUE NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    date_of_birth DATE NOT NULL,
    national_id VARCHAR(50) UNIQUE,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    department_id INT REFERENCES departments(id) ON DELETE SET NULL,
    designation_id INT REFERENCES designations(id) ON DELETE SET NULL,
    qualification VARCHAR(150),
    joining_date DATE NOT NULL,
    employment_type VARCHAR(30) DEFAULT 'Full-Time', -- 'Full-Time', 'Part-Time', 'Contract'
    status VARCHAR(20) DEFAULT 'Active',             -- 'Active', 'On Leave', 'Resigned', 'Terminated'
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(30),
    address TEXT,
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 3. PARENTS & GUARDIANS
-- =============================================================================

CREATE TABLE parents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    relation_type VARCHAR(30) NOT NULL,     -- 'Father', 'Mother', 'Legal Guardian'
    national_id VARCHAR(50) UNIQUE,
    phone VARCHAR(30) NOT NULL,
    alternate_phone VARCHAR(30),
    email VARCHAR(120),
    occupation VARCHAR(100),
    annual_income NUMERIC(14, 2),
    residential_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 4. STUDENTS
-- =============================================================================

CREATE TABLE students (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    admission_number VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    gender VARCHAR(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    date_of_birth DATE NOT NULL,
    blood_group VARCHAR(10),
    nationality VARCHAR(50) DEFAULT 'Domestic',
    religion VARCHAR(50),
    admission_date DATE NOT NULL,
    medical_history TEXT,
    status VARCHAR(20) DEFAULT 'Active',    -- 'Active', 'Graduated', 'Transferred', 'Suspended'
    residential_address TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE student_parents (
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    parent_id UUID NOT NULL REFERENCES parents(id) ON DELETE CASCADE,
    relationship VARCHAR(30) NOT NULL,      -- 'Father', 'Mother', 'Guardian'
    is_primary_contact BOOLEAN DEFAULT FALSE,
    can_pickup BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (student_id, parent_id)
);

-- =============================================================================
-- 5. CLASSES, SECTIONS & SUBJECTS
-- =============================================================================

CREATE TABLE class_levels (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,       -- e.g., 'Grade 1', 'Grade 10', 'Primary 4'
    code VARCHAR(20) UNIQUE
);

CREATE TABLE sections (
    id SERIAL PRIMARY KEY,
    class_level_id INT NOT NULL REFERENCES class_levels(id) ON DELETE CASCADE,
    name VARCHAR(20) NOT NULL,              -- e.g., 'A', 'B', 'Blue', 'Rose'
    capacity INT DEFAULT 40,
    room_number VARCHAR(30),
    class_teacher_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    UNIQUE (class_level_id, name)
);

CREATE TABLE student_enrollments (
    id SERIAL PRIMARY KEY,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    section_id INT NOT NULL REFERENCES sections(id) ON DELETE RESTRICT,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    roll_number VARCHAR(20),
    enrolled_at DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'Enrolled',   -- 'Enrolled', 'Promoted', 'Retained', 'Withdrawn'
    UNIQUE (student_id, academic_year_id)
);

CREATE TABLE subjects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(30) UNIQUE NOT NULL,
    type VARCHAR(20) DEFAULT 'Core',        -- 'Core', 'Elective', 'Optional'
    credit_hours NUMERIC(4, 1) DEFAULT 1.0,
    description TEXT
);

CREATE TABLE class_subjects (
    id SERIAL PRIMARY KEY,
    section_id INT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id INT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    teacher_id UUID REFERENCES staff(id) ON DELETE SET NULL,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    UNIQUE (section_id, subject_id, academic_year_id)
);

-- =============================================================================
-- 6. TIMETABLE & CALENDAR
-- =============================================================================

CREATE TABLE class_periods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,              -- e.g., 'Period 1', 'Lunch Break'
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_break BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 1
);

CREATE TABLE timetables (
    id SERIAL PRIMARY KEY,
    section_id INT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id INT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES staff(id) ON DELETE RESTRICT,
    period_id INT NOT NULL REFERENCES class_periods(id) ON DELETE CASCADE,
    day_of_week VARCHAR(15) NOT NULL CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    room_number VARCHAR(30),
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    UNIQUE (section_id, period_id, day_of_week, academic_year_id),
    UNIQUE (teacher_id, period_id, day_of_week, academic_year_id) -- Teacher conflict prevention
);

CREATE TABLE calendar_events (
    id SERIAL PRIMARY KEY,
    academic_year_id INT REFERENCES academic_years(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    event_type VARCHAR(50) DEFAULT 'General', -- 'Holiday', 'Exam', 'Sports', 'Parent-Teacher Meeting', 'Cultural'
    start_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    end_datetime TIMESTAMP WITH TIME ZONE NOT NULL,
    target_audience VARCHAR(30) DEFAULT 'All', -- 'All', 'Students', 'Teachers', 'Parents', 'Staff'
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 7. ATTENDANCE (STUDENTS & STAFF)
-- =============================================================================

CREATE TABLE student_attendance (
    id BIGSERIAL PRIMARY KEY,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    section_id INT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Present', 'Absent', 'Late', 'Excused', 'Half-Day')),
    arrival_time TIME,
    remarks VARCHAR(255),
    recorded_by UUID REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (student_id, attendance_date)
);

CREATE TABLE staff_attendance (
    id BIGSERIAL PRIMARY KEY,
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    attendance_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Present', 'Absent', 'Late', 'On Leave', 'Half-Day')),
    check_in TIME,
    check_out TIME,
    remarks VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (staff_id, attendance_date)
);

CREATE TABLE leave_applications (
    id SERIAL PRIMARY KEY,
    applicant_type VARCHAR(20) NOT NULL CHECK (applicant_type IN ('Staff', 'Student')),
    applicant_id UUID NOT NULL,             -- References staff(id) or students(id)
    leave_type VARCHAR(50) NOT NULL,        -- 'Sick Leave', 'Casual Leave', 'Maternity', 'Emergency'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    reviewed_by UUID REFERENCES staff(id) ON DELETE SET NULL,
    review_remarks TEXT,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 8. EXAMS, ASSESSMENTS & RESULTS
-- =============================================================================

CREATE TABLE grading_scales (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE        -- e.g., 'Standard Letter Grade', 'Percentage GPA'
);

CREATE TABLE grading_scale_rules (
    id SERIAL PRIMARY KEY,
    grading_scale_id INT NOT NULL REFERENCES grading_scales(id) ON DELETE CASCADE,
    grade_name VARCHAR(10) NOT NULL,        -- e.g., 'A+', 'A', 'B', 'F'
    min_score NUMERIC(5, 2) NOT NULL,
    max_score NUMERIC(5, 2) NOT NULL,
    grade_point NUMERIC(4, 2) NOT NULL,     -- e.g., 4.0, 3.5, 0.0
    description VARCHAR(100)
);

CREATE TABLE exams (
    id SERIAL PRIMARY KEY,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    academic_term_id INT NOT NULL REFERENCES academic_terms(id) ON DELETE RESTRICT,
    grading_scale_id INT NOT NULL REFERENCES grading_scales(id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,             -- e.g., 'Midterm Exam 2026', 'Final Exam'
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE exam_schedules (
    id SERIAL PRIMARY KEY,
    exam_id INT NOT NULL REFERENCES exams(id) ON DELETE CASCADE,
    section_id INT NOT NULL REFERENCES sections(id) ON DELETE CASCADE,
    subject_id INT NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_marks NUMERIC(5, 2) DEFAULT 100.00,
    pass_marks NUMERIC(5, 2) DEFAULT 40.00,
    room_number VARCHAR(30),
    UNIQUE (exam_id, section_id, subject_id)
);

CREATE TABLE exam_results (
    id BIGSERIAL PRIMARY KEY,
    exam_schedule_id INT NOT NULL REFERENCES exam_schedules(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    marks_obtained NUMERIC(5, 2) NOT NULL,
    grade_rule_id INT REFERENCES grading_scale_rules(id) ON DELETE SET NULL,
    is_absent BOOLEAN DEFAULT FALSE,
    remarks VARCHAR(255),
    evaluated_by UUID REFERENCES staff(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (exam_schedule_id, student_id)
);

-- =============================================================================
-- 9. FEES & PAYMENTS
-- =============================================================================

CREATE TABLE fee_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,      -- 'Tuition', 'Transportation', 'Library', 'Hostel', 'Exam Fee'
    description TEXT
);

CREATE TABLE fee_structures (
    id SERIAL PRIMARY KEY,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE CASCADE,
    class_level_id INT NOT NULL REFERENCES class_levels(id) ON DELETE CASCADE,
    fee_category_id INT NOT NULL REFERENCES fee_categories(id) ON DELETE RESTRICT,
    name VARCHAR(100) NOT NULL,             -- e.g., 'Grade 10 Tuition Fee Q1'
    amount NUMERIC(12, 2) NOT NULL,
    due_date DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fee_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    academic_year_id INT NOT NULL REFERENCES academic_years(id) ON DELETE RESTRICT,
    issue_date DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date DATE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    discount_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    paid_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    balance_due NUMERIC(12, 2) GENERATED ALWAYS AS (total_amount - discount_amount - paid_amount) STORED,
    status VARCHAR(20) DEFAULT 'Unpaid' CHECK (status IN ('Unpaid', 'Partially Paid', 'Paid', 'Overdue', 'Cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE fee_invoice_items (
    id SERIAL PRIMARY KEY,
    invoice_id UUID NOT NULL REFERENCES fee_invoices(id) ON DELETE CASCADE,
    fee_structure_id INT REFERENCES fee_structures(id) ON DELETE SET NULL,
    description VARCHAR(150) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL
);

CREATE TABLE fee_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    invoice_id UUID NOT NULL REFERENCES fee_invoices(id) ON DELETE RESTRICT,
    student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    receipt_number VARCHAR(50) UNIQUE NOT NULL,
    amount_paid NUMERIC(12, 2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL CHECK (payment_method IN ('Cash', 'Bank Transfer', 'Credit Card', 'Debit Card', 'Online Gateway', 'Cheque')),
    transaction_reference VARCHAR(100),
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    received_by UUID REFERENCES users(id) ON DELETE SET NULL,
    notes TEXT
);

-- =============================================================================
-- 10. EXPENSES & PAYROLL
-- =============================================================================

CREATE TABLE expense_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,      -- 'Utilities', 'Maintenance', 'Supplies', 'Lab Equipment', 'Events'
    description TEXT
);

CREATE TABLE expenses (
    id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES expense_categories(id) ON DELETE RESTRICT,
    title VARCHAR(150) NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
    payment_method VARCHAR(30) DEFAULT 'Bank Transfer',
    reference_number VARCHAR(100),
    receipt_attachment VARCHAR(255),
    approved_by UUID REFERENCES staff(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE salary_structures (
    id SERIAL PRIMARY KEY,
    staff_id UUID UNIQUE NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    base_salary NUMERIC(12, 2) NOT NULL,
    house_rent_allowance NUMERIC(12, 2) DEFAULT 0.00,
    transport_allowance NUMERIC(12, 2) DEFAULT 0.00,
    medical_allowance NUMERIC(12, 2) DEFAULT 0.00,
    tax_deduction NUMERIC(12, 2) DEFAULT 0.00,
    provident_fund NUMERIC(12, 2) DEFAULT 0.00,
    other_deductions NUMERIC(12, 2) DEFAULT 0.00,
    effective_from DATE NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payroll_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    staff_id UUID NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
    payroll_month INT NOT NULL CHECK (payroll_month BETWEEN 1 AND 12),
    payroll_year INT NOT NULL,
    base_amount NUMERIC(12, 2) NOT NULL,
    total_allowances NUMERIC(12, 2) DEFAULT 0.00,
    total_deductions NUMERIC(12, 2) DEFAULT 0.00,
    net_salary NUMERIC(12, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Processing', 'Paid', 'Failed')),
    payment_date DATE,
    payment_method VARCHAR(30) DEFAULT 'Bank Transfer',
    transaction_ref VARCHAR(100),
    payslip_url VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (staff_id, payroll_month, payroll_year)
);

-- =============================================================================
-- 11. MESSAGES & ANNOUNCEMENTS
-- =============================================================================

CREATE TABLE announcements (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    target_role_id INT REFERENCES roles(id) ON DELETE SET NULL, -- NULL means all roles
    priority VARCHAR(20) DEFAULT 'Normal' CHECK (priority IN ('Low', 'Normal', 'High', 'Urgent')),
    attachment_url VARCHAR(255),
    published_by UUID REFERENCES users(id) ON DELETE SET NULL,
    is_published BOOLEAN DEFAULT TRUE,
    published_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE messages (
    id BIGSERIAL PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id BIGINT REFERENCES messages(id) ON DELETE CASCADE,
    subject VARCHAR(200),
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE system_notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50) DEFAULT 'Info', -- 'Info', 'Alert', 'Payment', 'Exam', 'Attendance'
    is_read BOOLEAN DEFAULT FALSE,
    action_link VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 12. AUDIT LOGS & REPORTS
-- =============================================================================

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,            -- 'INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT'
    entity_table VARCHAR(60) NOT NULL,      -- e.g., 'students', 'fee_payments'
    entity_id VARCHAR(64),
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- 13. INDEXES FOR HIGH-PERFORMANCE QUERIES
-- =============================================================================

CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_staff_department_id ON staff(department_id);
CREATE INDEX idx_students_status ON students(status);
CREATE INDEX idx_student_enrollments_section_year ON student_enrollments(section_id, academic_year_id);
CREATE INDEX idx_student_attendance_date ON student_attendance(attendance_date, section_id);
CREATE INDEX idx_student_attendance_student ON student_attendance(student_id);
CREATE INDEX idx_staff_attendance_date ON staff_attendance(attendance_date);
CREATE INDEX idx_timetables_lookup ON timetables(section_id, day_of_week);
CREATE INDEX idx_exam_results_schedule ON exam_results(exam_schedule_id);
CREATE INDEX idx_fee_invoices_student_status ON fee_invoices(student_id, status);
CREATE INDEX idx_fee_payments_invoice ON fee_payments(invoice_id);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_payroll_runs_month_year ON payroll_runs(payroll_year, payroll_month);
CREATE INDEX idx_messages_receiver ON messages(receiver_id, is_read);
CREATE INDEX idx_notifications_user ON system_notifications(user_id, is_read);

-- =============================================================================
-- 14. MAIN DASHBOARD VIEWS & ANALYTICS
-- =============================================================================

-- View 1: Main High-Level Dashboard KPI Counters
CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT
    (SELECT COUNT(*) FROM students WHERE status = 'Active') AS total_active_students,
    (SELECT COUNT(*) FROM staff WHERE status = 'Active') AS total_active_teachers_staff,
    (SELECT COUNT(*) FROM parents) AS total_parents,
    (SELECT COUNT(*) FROM sections) AS total_sections,
    (SELECT COALESCE(SUM(amount_paid), 0) FROM fee_payments WHERE payment_date >= DATE_TRUNC('month', CURRENT_DATE)) AS current_month_fee_collected,
    (SELECT COALESCE(SUM(balance_due), 0) FROM fee_invoices WHERE status IN ('Unpaid', 'Partially Paid', 'Overdue')) AS total_outstanding_fee_dues,
    (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE expense_date >= DATE_TRUNC('month', CURRENT_DATE)) AS current_month_expenses,
    (SELECT COALESCE(SUM(net_salary), 0) FROM payroll_runs WHERE payment_status = 'Paid' AND payroll_month = EXTRACT(MONTH FROM CURRENT_DATE) AND payroll_year = EXTRACT(YEAR FROM CURRENT_DATE)) AS current_month_payroll_paid;

-- View 2: Today's Student & Staff Attendance Breakdown
CREATE OR REPLACE VIEW vw_dashboard_today_attendance AS
SELECT 
    'Students' AS cohort,
    COUNT(*) AS total_recorded,
    COUNT(*) FILTER (WHERE status = 'Present') AS present_count,
    COUNT(*) FILTER (WHERE status = 'Absent') AS absent_count,
    COUNT(*) FILTER (WHERE status = 'Late') AS late_count,
    ROUND(COUNT(*) FILTER (WHERE status = 'Present') * 100.0 / NULLIF(COUNT(*), 0), 2) AS attendance_rate_pct
FROM student_attendance
WHERE attendance_date = CURRENT_DATE
UNION ALL
SELECT 
    'Staff' AS cohort,
    COUNT(*) AS total_recorded,
    COUNT(*) FILTER (WHERE status = 'Present') AS present_count,
    COUNT(*) FILTER (WHERE status = 'Absent') AS absent_count,
    COUNT(*) FILTER (WHERE status = 'Late') AS late_count,
    ROUND(COUNT(*) FILTER (WHERE status = 'Present') * 100.0 / NULLIF(COUNT(*), 0), 2) AS attendance_rate_pct
FROM staff_attendance
WHERE attendance_date = CURRENT_DATE;

-- View 3: Section Strength and Student Enrollment Overview
CREATE OR REPLACE VIEW vw_class_enrollment_summary AS
SELECT 
    cl.name AS class_name,
    s.name AS section_name,
    s.capacity,
    COUNT(se.id) AS enrolled_students,
    s.capacity - COUNT(se.id) AS available_seats,
    CONCAT(st.first_name, ' ', st.last_name) AS class_teacher
FROM sections s
JOIN class_levels cl ON s.class_level_id = cl.id
LEFT JOIN student_enrollments se ON s.id = se.section_id AND se.status = 'Enrolled'
LEFT JOIN staff st ON s.class_teacher_id = st.id
GROUP BY cl.name, s.name, s.capacity, st.first_name, st.last_name;

-- View 4: Student Exam Performance Breakdown
CREATE OR REPLACE VIEW vw_exam_performance_summary AS
SELECT 
    e.name AS exam_name,
    cl.name AS class_name,
    sec.name AS section_name,
    sub.name AS subject_name,
    es.max_marks,
    es.pass_marks,
    COUNT(er.id) AS students_evaluated,
    ROUND(AVG(er.marks_obtained), 2) AS average_marks,
    MAX(er.marks_obtained) AS highest_marks,
    MIN(er.marks_obtained) AS lowest_marks,
    COUNT(*) FILTER (WHERE er.marks_obtained >= es.pass_marks) AS passed_students,
    ROUND(COUNT(*) FILTER (WHERE er.marks_obtained >= es.pass_marks) * 100.0 / NULLIF(COUNT(er.id), 0), 2) AS pass_percentage
FROM exam_results er
JOIN exam_schedules es ON er.exam_schedule_id = es.id
JOIN exams e ON es.exam_id = e.id
JOIN sections sec ON es.section_id = sec.id
JOIN class_levels cl ON sec.class_level_id = cl.id
JOIN subjects sub ON es.subject_id = sub.id
GROUP BY e.name, cl.name, sec.name, sub.name, es.max_marks, es.pass_marks;
