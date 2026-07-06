-- =========================================================
-- schema.sql
-- Part 1 - Task 1.2
-- BCNF Schema Implementation
-- =========================================================

-- =========================================================
-- Table: Advisors
-- =========================================================

CREATE TABLE Advisors (
    advisor_id INT PRIMARY KEY,
    advisor_name VARCHAR(100) NOT NULL,
    advisor_email VARCHAR(150) UNIQUE NOT NULL
);

-- =========================================================
-- Table: Instructors
-- =========================================================

CREATE TABLE Instructors (
    instructor_id INT PRIMARY KEY,
    instructor_name VARCHAR(100) NOT NULL,
    instructor_email VARCHAR(150) UNIQUE NOT NULL
);

-- =========================================================
-- Table: Students
-- =========================================================

CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    advisor_id INT,

    CONSTRAINT fk_student_advisor
        FOREIGN KEY (advisor_id)
        REFERENCES Advisors(advisor_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);

-- =========================================================
-- Table: Courses
-- =========================================================

CREATE TABLE Courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_id INT NOT NULL,

    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_id)
        REFERENCES Instructors(instructor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================================
-- Table: Enrollments
-- =========================================================

CREATE TABLE Enrollments (
    student_id INT,
    course_code VARCHAR(10),
    enrollment_year INT DEFAULT 2025,
    marks_obtained DECIMAL(5,2)
        CHECK (marks_obtained BETWEEN 0 AND 100),

    CONSTRAINT pk_enrollments
        PRIMARY KEY (student_id, course_code),

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES Students(student_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_code)
        REFERENCES Courses(course_code)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- =========================================================
-- Original Flat Table
-- (Required for Task 1.3(d))
-- =========================================================

CREATE TABLE StudentRecords (
    student_id INT,
    student_name VARCHAR(100),
    department VARCHAR(100),
    advisor_name VARCHAR(100),
    advisor_email VARCHAR(150),
    course_code VARCHAR(10),
    course_name VARCHAR(100),
    instructor_name VARCHAR(100),
    instructor_email VARCHAR(150),
    enrollment_year INT,
    marks_obtained DECIMAL(5,2)
);
