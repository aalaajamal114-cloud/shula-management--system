-- =============================================================================
-- Initial Setup & Configuration for School Management System (SMS)
-- Grades: 1, 2, 3, 4, 5, 6, 7, 8, F1, F2, F3, F4
-- Subject Tiers:
--   - G1 to G4: 8 Subjects
--   - G5 to G8: 9 Subjects
--   - F1 to F4: 13 Subjects
-- =============================================================================

-- 1. Roles & Permissions
INSERT INTO roles (id, name, slug, description) VALUES
(1, 'Super Administrator', 'super_admin', 'Full platform access'),
(2, 'School Principal', 'principal', 'Academic and administrative executive access'),
(3, 'Teacher', 'teacher', 'Grade, attendance, and timetable management'),
(4, 'Student', 'student', 'Portal access for marks, timetable, and attendance'),
(5, 'Parent / Guardian', 'parent', 'Portal access for child performance and fee payment'),
(6, 'Accountant', 'accountant', 'Fee collection, invoicing, expense tracking, payroll');

-- 2. Academic Calendar
INSERT INTO academic_years (id, name, start_date, end_date, is_current) VALUES
(1, '2026-2027', '2026-09-01', '2027-06-30', TRUE);

INSERT INTO academic_terms (id, academic_year_id, name, start_date, end_date, is_current) VALUES
(1, 1, 'First Term', '2026-09-01', '2026-12-20', TRUE),
(2, 1, 'Second Term', '2027-01-10', '2027-06-30', FALSE);

-- 3. System Settings
INSERT INTO system_settings (id, school_name, school_code, tagline, email, phone, currency_code, currency_symbol, current_academic_year_id) VALUES
(1, 'School Management System', 'SMS-2026', 'Excellence in Education', 'admin@school.edu', '+1-555-010-0000', 'USD', '$', 1);

-- 4. The 12 Exact Configured Grade Levels (1, 2, 3, 4, 5, 6, 7, 8, F1, F2, F3, F4)
INSERT INTO class_levels (id, name, code) VALUES
(1, 'Grade 1', 'G01'),
(2, 'Grade 2', 'G02'),
(3, 'Grade 3', 'G03'),
(4, 'Grade 4', 'G04'),
(5, 'Grade 5', 'G05'),
(6, 'Grade 6', 'G06'),
(7, 'Grade 7', 'G07'),
(8, 'Grade 8', 'G08'),
(9, 'F1', 'F01'),
(10, 'F2', 'F02'),
(11, 'F3', 'F03'),
(12, 'F4', 'F04');

-- 5. Standard Sections for Each Grade
INSERT INTO sections (class_level_id, name, capacity) VALUES
(1, 'Section A', 35),
(2, 'Section A', 35),
(3, 'Section A', 35),
(4, 'Section A', 35),
(5, 'Section A', 35),
(6, 'Section A', 35),
(7, 'Section A', 35),
(8, 'Section A', 35),
(9, 'Section A', 35),
(10, 'Section A', 35),
(11, 'Section A', 35),
(12, 'Section A', 35);

-- 6. Subject Catalog: G1-G4 (8 subjects), G5-G8 (9 subjects), F1-F4 (13 subjects)
INSERT INTO subjects (id, name, code, type, credit_hours) VALUES
-- G1 - G4 Subjects (8)
(1, 'Mathematics', 'G14-MATH', 'Core', 4.0),
(2, 'English Language', 'G14-ENG', 'Core', 4.0),
(3, 'General Science', 'G14-SCI', 'Core', 3.0),
(4, 'Social Studies', 'G14-SOC', 'Core', 3.0),
(5, 'Art & Craft', 'G14-ART', 'Core', 2.0),
(6, 'Physical Education (PE)', 'G14-PE', 'Core', 2.0),
(7, 'Music & Performing Arts', 'G14-MUS', 'Core', 2.0),
(8, 'Moral & Health Education', 'G14-MHE', 'Core', 2.0),

-- G5 - G8 Additional & Specific Subjects (Total 9)
(9, 'Integrated Science', 'G58-ISCI', 'Core', 3.5),
(10, 'Social Studies & History', 'G58-HIST', 'Core', 3.0),
(11, 'Computer Science / ICT', 'G58-ICT', 'Core', 2.5),
(12, 'Physical Education & Health', 'G58-PEH', 'Core', 2.0),
(13, 'Creative Arts', 'G58-CART', 'Core', 2.0),
(14, 'Religious / Moral Studies', 'G58-REL', 'Core', 2.0),
(15, 'Foreign Language', 'G58-FLANG', 'Core', 2.5),

-- F1 - F4 Senior Form Subjects (Total 13)
(16, 'Physics', 'F-PHY', 'Core', 4.0),
(17, 'Chemistry', 'F-CHEM', 'Core', 4.0),
(18, 'Biology', 'F-BIO', 'Core', 4.0),
(19, 'History & Civics', 'F-CIV', 'Core', 3.0),
(20, 'Geography', 'F-GEO', 'Core', 3.0),
(21, 'Business Studies', 'F-BUS', 'Core', 3.0),
(22, 'Principles of Accounts', 'F-ACC', 'Core', 3.0),
(23, 'Agriculture Science', 'F-AGR', 'Core', 3.0),
(24, 'English Literature', 'F-LIT', 'Core', 3.5);

-- 7. Standard Grading Scale (A-F)
INSERT INTO grading_scales (id, name) VALUES (1, 'Standard Grade Scale');

INSERT INTO grading_scale_rules (grading_scale_id, grade_name, min_score, max_score, grade_point, description) VALUES
(1, 'A+', 90.00, 100.00, 4.00, 'Distinction'),
(1, 'A',  80.00,  89.99, 3.75, 'Excellent'),
(1, 'B',  70.00,  79.99, 3.00, 'Good'),
(1, 'C',  60.00,  69.99, 2.00, 'Satisfactory'),
(1, 'D',  50.00,  59.99, 1.00, 'Pass'),
(1, 'F',   0.00,  49.99, 0.00, 'Fail');

-- 8. Standard Bell Schedule Periods
INSERT INTO class_periods (id, name, start_time, end_time, is_break, sort_order) VALUES
(1, 'Period 1', '08:00:00', '08:50:00', FALSE, 1),
(2, 'Period 2', '08:55:00', '09:45:00', FALSE, 2),
(3, 'Morning Recess', '09:45:00', '10:15:00', TRUE, 3),
(4, 'Period 3', '10:15:00', '11:05:00', FALSE, 4);

-- 9. Fee Categories
INSERT INTO fee_categories (id, name, description) VALUES
(1, 'Tuition Fee', 'Regular academic term tuition fee'),
(2, 'Laboratory & IT Fee', 'Science & computing laboratory access');
