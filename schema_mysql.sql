-- =============================================================================
-- Comprehensive School Management System (SMS) Database Schema
-- Dialect: MySQL 8.0+ / MariaDB 10.5+
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- 1. SETTINGS & USER PERMISSIONS (RBAC)
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS system_settings;
DROP TABLE IF EXISTS academic_terms;
DROP TABLE IF EXISTS academic_years;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

CREATE TABLE roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    module VARCHAR(50) NOT NULL,
    action VARCHAR(50) NOT NULL,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    role_id INT NOT NULL,
    username VARCHAR(60) UNIQUE NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(30) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    avatar_url VARCHAR(255),
    last_login_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE academic_years (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE academic_terms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_terms_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
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
    current_academic_year_id INT,
    config_json JSON,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_settings_year FOREIGN KEY (current_academic_year_id) REFERENCES academic_years(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. TEACHERS & STAFF
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS designations;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(20) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE designations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT,
    title VARCHAR(100) NOT NULL,
    CONSTRAINT fk_desig_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE staff (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) UNIQUE,
    staff_code VARCHAR(30) UNIQUE NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    date_of_birth DATE NOT NULL,
    national_id VARCHAR(50) UNIQUE,
    email VARCHAR(120) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    department_id INT,
    designation_id INT,
    qualification VARCHAR(150),
    joining_date DATE NOT NULL,
    employment_type ENUM('Full-Time', 'Part-Time', 'Contract') DEFAULT 'Full-Time',
    status ENUM('Active', 'On Leave', 'Resigned', 'Terminated') DEFAULT 'Active',
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(30),
    address TEXT,
    bank_name VARCHAR(100),
    bank_account_number VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    CONSTRAINT fk_staff_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT fk_staff_desig FOREIGN KEY (designation_id) REFERENCES designations(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. PARENTS & GUARDIANS
DROP TABLE IF EXISTS parents;

CREATE TABLE parents (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) UNIQUE,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    relation_type VARCHAR(30) NOT NULL,
    national_id VARCHAR(50) UNIQUE,
    phone VARCHAR(30) NOT NULL,
    alternate_phone VARCHAR(30),
    email VARCHAR(120),
    occupation VARCHAR(100),
    annual_income DECIMAL(14, 2),
    residential_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_parents_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. STUDENTS
DROP TABLE IF EXISTS student_parents;
DROP TABLE IF EXISTS students;

CREATE TABLE students (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) UNIQUE,
    admission_number VARCHAR(50) UNIQUE NOT NULL,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    date_of_birth DATE NOT NULL,
    blood_group VARCHAR(10),
    nationality VARCHAR(50) DEFAULT 'Domestic',
    religion VARCHAR(50),
    admission_date DATE NOT NULL,
    medical_history TEXT,
    status ENUM('Active', 'Graduated', 'Transferred', 'Suspended') DEFAULT 'Active',
    residential_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_parents (
    student_id CHAR(36) NOT NULL,
    parent_id CHAR(36) NOT NULL,
    relationship VARCHAR(30) NOT NULL,
    is_primary_contact BOOLEAN DEFAULT FALSE,
    can_pickup BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (student_id, parent_id),
    CONSTRAINT fk_sp_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_sp_parent FOREIGN KEY (parent_id) REFERENCES parents(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. CLASSES, SECTIONS & SUBJECTS
DROP TABLE IF EXISTS class_subjects;
DROP TABLE IF EXISTS student_enrollments;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS class_levels;

CREATE TABLE class_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    code VARCHAR(20) UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    class_level_id INT NOT NULL,
    name VARCHAR(20) NOT NULL,
    capacity INT DEFAULT 40,
    room_number VARCHAR(30),
    class_teacher_id CHAR(36),
    UNIQUE KEY uq_class_sec (class_level_id, name),
    CONSTRAINT fk_sec_level FOREIGN KEY (class_level_id) REFERENCES class_levels(id) ON DELETE CASCADE,
    CONSTRAINT fk_sec_teacher FOREIGN KEY (class_teacher_id) REFERENCES staff(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(30) UNIQUE NOT NULL,
    type ENUM('Core', 'Elective', 'Optional') DEFAULT 'Core',
    credit_hours DECIMAL(4, 1) DEFAULT 1.0,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE student_enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(36) NOT NULL,
    section_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    roll_number VARCHAR(20),
    enrolled_at DATE NOT NULL,
    status ENUM('Enrolled', 'Promoted', 'Retained', 'Withdrawn') DEFAULT 'Enrolled',
    UNIQUE KEY uq_student_year (student_id, academic_year_id),
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_enr_section FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE RESTRICT,
    CONSTRAINT fk_enr_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE class_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id CHAR(36),
    academic_year_id INT NOT NULL,
    UNIQUE KEY uq_sec_sub_yr (section_id, subject_id, academic_year_id),
    CONSTRAINT fk_cs_sec FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
    CONSTRAINT fk_cs_sub FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CONSTRAINT fk_cs_teacher FOREIGN KEY (teacher_id) REFERENCES staff(id) ON DELETE SET NULL,
    CONSTRAINT fk_cs_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. TIMETABLE & CALENDAR
DROP TABLE IF EXISTS timetables;
DROP TABLE IF EXISTS class_periods;
DROP TABLE IF EXISTS calendar_events;

CREATE TABLE class_periods (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_break BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE timetables (
    id INT AUTO_INCREMENT PRIMARY KEY,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id CHAR(36) NOT NULL,
    period_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    room_number VARCHAR(30),
    academic_year_id INT NOT NULL,
    UNIQUE KEY uq_tt_sec_period (section_id, period_id, day_of_week, academic_year_id),
    UNIQUE KEY uq_tt_teacher_period (teacher_id, period_id, day_of_week, academic_year_id),
    CONSTRAINT fk_tt_sec FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
    CONSTRAINT fk_tt_sub FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
    CONSTRAINT fk_tt_staff FOREIGN KEY (teacher_id) REFERENCES staff(id) ON DELETE RESTRICT,
    CONSTRAINT fk_tt_period FOREIGN KEY (period_id) REFERENCES class_periods(id) ON DELETE CASCADE,
    CONSTRAINT fk_tt_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE calendar_events (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    event_type ENUM('General', 'Holiday', 'Exam', 'Sports', 'Parent-Teacher Meeting', 'Cultural') DEFAULT 'General',
    start_datetime DATETIME NOT NULL,
    end_datetime DATETIME NOT NULL,
    target_audience ENUM('All', 'Students', 'Teachers', 'Parents', 'Staff') DEFAULT 'All',
    created_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ce_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
    CONSTRAINT fk_ce_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. ATTENDANCE & LEAVES
DROP TABLE IF EXISTS student_attendance;
DROP TABLE IF EXISTS staff_attendance;
DROP TABLE IF EXISTS leave_applications;

CREATE TABLE student_attendance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id CHAR(36) NOT NULL,
    section_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late', 'Excused', 'Half-Day') NOT NULL,
    arrival_time TIME,
    remarks VARCHAR(255),
    recorded_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_student_att_date (student_id, attendance_date),
    CONSTRAINT fk_sa_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_sa_sec FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
    CONSTRAINT fk_sa_staff FOREIGN KEY (recorded_by) REFERENCES staff(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE staff_attendance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    staff_id CHAR(36) NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late', 'On Leave', 'Half-Day') NOT NULL,
    check_in TIME,
    check_out TIME,
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_staff_att_date (staff_id, attendance_date),
    CONSTRAINT fk_stf_att FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE leave_applications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    applicant_type ENUM('Staff', 'Student') NOT NULL,
    applicant_id CHAR(36) NOT NULL,
    leave_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status ENUM('Pending', 'Approved', 'Rejected', 'Cancelled') DEFAULT 'Pending',
    reviewed_by CHAR(36),
    review_remarks TEXT,
    reviewed_at DATETIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_la_reviewer FOREIGN KEY (reviewed_by) REFERENCES staff(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. EXAMS & RESULTS
DROP TABLE IF EXISTS exam_results;
DROP TABLE IF EXISTS exam_schedules;
DROP TABLE IF EXISTS exams;
DROP TABLE IF EXISTS grading_scale_rules;
DROP TABLE IF EXISTS grading_scales;

CREATE TABLE grading_scales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE grading_scale_rules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    grading_scale_id INT NOT NULL,
    grade_name VARCHAR(10) NOT NULL,
    min_score DECIMAL(5, 2) NOT NULL,
    max_score DECIMAL(5, 2) NOT NULL,
    grade_point DECIMAL(4, 2) NOT NULL,
    description VARCHAR(100),
    CONSTRAINT fk_gsr_scale FOREIGN KEY (grading_scale_id) REFERENCES grading_scales(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exams (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT NOT NULL,
    academic_term_id INT NOT NULL,
    grading_scale_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ex_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
    CONSTRAINT fk_ex_term FOREIGN KEY (academic_term_id) REFERENCES academic_terms(id) ON DELETE RESTRICT,
    CONSTRAINT fk_ex_scale FOREIGN KEY (grading_scale_id) REFERENCES grading_scales(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exam_schedules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    section_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    max_marks DECIMAL(5, 2) DEFAULT 100.00,
    pass_marks DECIMAL(5, 2) DEFAULT 40.00,
    room_number VARCHAR(30),
    UNIQUE KEY uq_exam_sec_sub (exam_id, section_id, subject_id),
    CONSTRAINT fk_es_exam FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE,
    CONSTRAINT fk_es_sec FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE,
    CONSTRAINT fk_es_sub FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE exam_results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    exam_schedule_id INT NOT NULL,
    student_id CHAR(36) NOT NULL,
    marks_obtained DECIMAL(5, 2) NOT NULL,
    grade_rule_id INT,
    is_absent BOOLEAN DEFAULT FALSE,
    remarks VARCHAR(255),
    evaluated_by CHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_res_exam_std (exam_schedule_id, student_id),
    CONSTRAINT fk_er_sched FOREIGN KEY (exam_schedule_id) REFERENCES exam_schedules(id) ON DELETE CASCADE,
    CONSTRAINT fk_er_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_er_rule FOREIGN KEY (grade_rule_id) REFERENCES grading_scale_rules(id) ON DELETE SET NULL,
    CONSTRAINT fk_er_staff FOREIGN KEY (evaluated_by) REFERENCES staff(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. FEES & PAYMENTS
DROP TABLE IF EXISTS fee_payments;
DROP TABLE IF EXISTS fee_invoice_items;
DROP TABLE IF EXISTS fee_invoices;
DROP TABLE IF EXISTS fee_structures;
DROP TABLE IF EXISTS fee_categories;

CREATE TABLE fee_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fee_structures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year_id INT NOT NULL,
    class_level_id INT NOT NULL,
    fee_category_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    due_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fs_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE CASCADE,
    CONSTRAINT fk_fs_level FOREIGN KEY (class_level_id) REFERENCES class_levels(id) ON DELETE CASCADE,
    CONSTRAINT fk_fs_cat FOREIGN KEY (fee_category_id) REFERENCES fee_categories(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fee_invoices (
    id CHAR(36) PRIMARY KEY,
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    student_id CHAR(36) NOT NULL,
    academic_year_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    paid_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    balance_due DECIMAL(12, 2) AS (total_amount - discount_amount - paid_amount) STORED,
    status ENUM('Unpaid', 'Partially Paid', 'Paid', 'Overdue', 'Cancelled') DEFAULT 'Unpaid',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fi_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_fi_year FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fee_invoice_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id CHAR(36) NOT NULL,
    fee_structure_id INT,
    description VARCHAR(150) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    CONSTRAINT fk_fii_inv FOREIGN KEY (invoice_id) REFERENCES fee_invoices(id) ON DELETE CASCADE,
    CONSTRAINT fk_fii_fs FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE fee_payments (
    id CHAR(36) PRIMARY KEY,
    invoice_id CHAR(36) NOT NULL,
    student_id CHAR(36) NOT NULL,
    receipt_number VARCHAR(50) UNIQUE NOT NULL,
    amount_paid DECIMAL(12, 2) NOT NULL,
    payment_method ENUM('Cash', 'Bank Transfer', 'Credit Card', 'Debit Card', 'Online Gateway', 'Cheque') NOT NULL,
    transaction_reference VARCHAR(100),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    received_by CHAR(36),
    notes TEXT,
    CONSTRAINT fk_fp_inv FOREIGN KEY (invoice_id) REFERENCES fee_invoices(id) ON DELETE RESTRICT,
    CONSTRAINT fk_fp_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_fp_user FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. EXPENSES & PAYROLL
DROP TABLE IF EXISTS payroll_runs;
DROP TABLE IF EXISTS salary_structures;
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS expense_categories;

CREATE TABLE expense_categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE expenses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    expense_date DATE NOT NULL,
    payment_method VARCHAR(30) DEFAULT 'Bank Transfer',
    reference_number VARCHAR(100),
    receipt_attachment VARCHAR(255),
    approved_by CHAR(36),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_exp_cat FOREIGN KEY (category_id) REFERENCES expense_categories(id) ON DELETE RESTRICT,
    CONSTRAINT fk_exp_appr FOREIGN KEY (approved_by) REFERENCES staff(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE salary_structures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_id CHAR(36) UNIQUE NOT NULL,
    base_salary DECIMAL(12, 2) NOT NULL,
    house_rent_allowance DECIMAL(12, 2) DEFAULT 0.00,
    transport_allowance DECIMAL(12, 2) DEFAULT 0.00,
    medical_allowance DECIMAL(12, 2) DEFAULT 0.00,
    tax_deduction DECIMAL(12, 2) DEFAULT 0.00,
    provident_fund DECIMAL(12, 2) DEFAULT 0.00,
    other_deductions DECIMAL(12, 2) DEFAULT 0.00,
    effective_from DATE NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_sal_staff FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payroll_runs (
    id CHAR(36) PRIMARY KEY,
    staff_id CHAR(36) NOT NULL,
    payroll_month INT NOT NULL,
    payroll_year INT NOT NULL,
    base_amount DECIMAL(12, 2) NOT NULL,
    total_allowances DECIMAL(12, 2) DEFAULT 0.00,
    total_deductions DECIMAL(12, 2) DEFAULT 0.00,
    net_salary DECIMAL(12, 2) NOT NULL,
    payment_status ENUM('Pending', 'Processing', 'Paid', 'Failed') DEFAULT 'Pending',
    payment_date DATE,
    payment_method VARCHAR(30) DEFAULT 'Bank Transfer',
    transaction_ref VARCHAR(100),
    payslip_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_payroll_period (staff_id, payroll_month, payroll_year),
    CONSTRAINT fk_pr_staff FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 11. MESSAGES & ANNOUNCEMENTS
DROP TABLE IF EXISTS system_notifications;
DROP TABLE IF EXISTS messages;
DROP TABLE IF EXISTS announcements;

CREATE TABLE announcements (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    target_role_id INT,
    priority ENUM('Low', 'Normal', 'High', 'Urgent') DEFAULT 'Normal',
    attachment_url VARCHAR(255),
    published_by CHAR(36),
    is_published BOOLEAN DEFAULT TRUE,
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    CONSTRAINT fk_ann_role FOREIGN KEY (target_role_id) REFERENCES roles(id) ON DELETE SET NULL,
    CONSTRAINT fk_ann_user FOREIGN KEY (published_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE messages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id CHAR(36) NOT NULL,
    receiver_id CHAR(36) NOT NULL,
    parent_id BIGINT,
    subject VARCHAR(200),
    body TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_msg_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_msg_recv FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_msg_parent FOREIGN KEY (parent_id) REFERENCES messages(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE system_notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    title VARCHAR(150) NOT NULL,
    body TEXT NOT NULL,
    notification_type VARCHAR(50) DEFAULT 'Info',
    is_read BOOLEAN DEFAULT FALSE,
    action_link VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. AUDIT LOGS
DROP TABLE IF EXISTS audit_logs;

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id CHAR(36),
    action VARCHAR(50) NOT NULL,
    entity_table VARCHAR(60) NOT NULL,
    entity_id VARCHAR(64),
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET FOREIGN_KEY_CHECKS = 1;

-- 13. DASHBOARD VIEWS
CREATE OR REPLACE VIEW vw_dashboard_kpis AS
SELECT
    (SELECT COUNT(*) FROM students WHERE status = 'Active') AS total_active_students,
    (SELECT COUNT(*) FROM staff WHERE status = 'Active') AS total_active_teachers_staff,
    (SELECT COUNT(*) FROM parents) AS total_parents,
    (SELECT COUNT(*) FROM sections) AS total_sections,
    (SELECT COALESCE(SUM(amount_paid), 0) FROM fee_payments WHERE payment_date >= DATE_SUB(CURRENT_DATE, INTERVAL DAYOFMONTH(CURRENT_DATE)-1 DAY)) AS current_month_fee_collected,
    (SELECT COALESCE(SUM(balance_due), 0) FROM fee_invoices WHERE status IN ('Unpaid', 'Partially Paid', 'Overdue')) AS total_outstanding_fee_dues,
    (SELECT COALESCE(SUM(amount), 0) FROM expenses WHERE expense_date >= DATE_SUB(CURRENT_DATE, INTERVAL DAYOFMONTH(CURRENT_DATE)-1 DAY)) AS current_month_expenses,
    (SELECT COALESCE(SUM(net_salary), 0) FROM payroll_runs WHERE payment_status = 'Paid' AND payroll_month = MONTH(CURRENT_DATE) AND payroll_year = YEAR(CURRENT_DATE)) AS current_month_payroll_paid;
