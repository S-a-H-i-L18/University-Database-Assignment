-- =========================================================
-- queries.sql
-- Part 1
-- Task 1.3 - Data Manipulation Language (DML)
-- =========================================================

-- =========================================================
-- Task 1.3(a)
-- Insert at least three students, two advisors,
-- two instructors, two courses and enrollment records
-- =========================================================

-- Insert Advisors

INSERT INTO Advisors (advisor_id, advisor_name, advisor_email)
VALUES
(101, 'Dr. Sharma', 'sharma@university.edu'),
(102, 'Dr. Gupta', 'gupta@university.edu');

------------------------------------------------------------

-- Insert Instructors

INSERT INTO Instructors (instructor_id, instructor_name, instructor_email)
VALUES
(201, 'Prof. Mehta', 'mehta@university.edu'),
(202, 'Prof. Singh', 'singh@university.edu');

------------------------------------------------------------

-- Insert Students

INSERT INTO Students
(student_id, student_name, department, advisor_id)
VALUES
(1, 'Aman', 'Computer Science', 101),
(2, 'Priya', 'Computer Science', 101),
(3, 'Rahul', 'Information Technology', 102);

------------------------------------------------------------

-- Insert Courses

INSERT INTO Courses
(course_code, course_name, instructor_id)
VALUES
('CS101', 'Database Management Systems', 201),
('CS303', 'Operating Systems', 202);

------------------------------------------------------------

-- Insert Enrollment Records

INSERT INTO Enrollments
(student_id, course_code, enrollment_year, marks_obtained)
VALUES
(1, 'CS101', 2024, 82.50),
(2, 'CS303', 2025, 74.00),
(3, 'CS101', 2025, 30.00);

-- =========================================================
-- Task 1.3(b)
-- Update instructor email using primary key
-- =========================================================

UPDATE Instructors
SET instructor_email = 'mehta_updated@university.edu'
WHERE instructor_id = 201;

-- =========================================================
-- Task 1.3(c)
-- Delete enrollment records where marks < 35
-- =========================================================

DELETE FROM Enrollments
WHERE marks_obtained < 35;

-- =========================================================
-- Task 1.3(d)
-- Delete all rows from old StudentRecords table
-- =========================================================

/*
DELETE is used instead of TRUNCATE because DELETE is a
DML statement that works safely inside transactions.

DELETE supports BEGIN, COMMIT and ROLLBACK in all major
database systems.

TRUNCATE behaves differently across database engines.

In MySQL, TRUNCATE is treated as DDL and performs an
implicit COMMIT, making rollback impossible.

PostgreSQL allows transactional TRUNCATE, but DELETE
remains the safest cross-database option.
*/

DELETE FROM StudentRecords;

-- =========================================================
-- Task 1.4(a)
-- Students enrolled in CS101 or CS303
-- Using IN operator
-- =========================================================

SELECT
    s.student_name,
    c.course_name
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
INNER JOIN Courses c
ON e.course_code = c.course_code
WHERE e.course_code IN ('CS101', 'CS303');

-- =========================================================
-- Task 1.4(b)
-- Marks between 60 and 85
-- Advisor email should not be NULL
-- =========================================================

SELECT
    s.student_name,
    e.marks_obtained,
    a.advisor_email
FROM Students s
INNER JOIN Advisors a
ON s.advisor_id = a.advisor_id
INNER JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.marks_obtained BETWEEN 60 AND 85
AND a.advisor_email IS NOT NULL;

-- =========================================================
-- Task 1.4(c)
-- Average, Minimum and Maximum Marks Department-wise
-- =========================================================

SELECT
    s.department,
    AVG(e.marks_obtained) AS average_marks,
    MIN(e.marks_obtained) AS minimum_marks,
    MAX(e.marks_obtained) AS maximum_marks
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
GROUP BY s.department
HAVING AVG(e.marks_obtained) > 55;

-- =========================================================
-- Task 1.4(d)
-- INNER JOIN
-- =========================================================

SELECT
    s.student_name,
    c.course_name,
    e.marks_obtained
FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id
INNER JOIN Courses c
ON e.course_code = c.course_code;

------------------------------------------------------------
-- LEFT JOIN
------------------------------------------------------------

SELECT
    s.student_name,
    c.course_name,
    e.marks_obtained
FROM Students s
LEFT JOIN Enrollments e
ON s.student_id = e.student_id
LEFT JOIN Courses c
ON e.course_code = c.course_code;
-- =========================================================
-- Task 1.4(e)
-- Correlated Subquery
-- Retrieve students who scored higher than the average
-- marks in their own department.
-- =========================================================

SELECT
    s.student_name,
    s.department,
    e.marks_obtained
FROM Students s
INNER JOIN Enrollments e
    ON s.student_id = e.student_id
WHERE e.marks_obtained >
(
    SELECT AVG(e2.marks_obtained)
    FROM Students s2
    INNER JOIN Enrollments e2
        ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
);

-- =========================================================
-- Task 1.4(f)
-- Find student_ids present in 2024 enrollments
-- but not in 2025 enrollments
-- Using EXCEPT
-- =========================================================

SELECT student_id
FROM Enrollments
WHERE enrollment_year = 2024

EXCEPT

SELECT student_id
FROM Enrollments
WHERE enrollment_year = 2025;

-- =========================================================
-- Task 1.4(g)
-- Correlated Subquery
-- Retrieve the second-highest scorer in each department.
-- Departments having only one student are excluded.
-- =========================================================

SELECT
    s.department,
    s.student_name,
    e.marks_obtained
FROM Students s
INNER JOIN Enrollments e
    ON s.student_id = e.student_id
WHERE 1 =
(
    SELECT COUNT(DISTINCT e2.marks_obtained)
    FROM Students s2
    INNER JOIN Enrollments e2
        ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
      AND e2.marks_obtained > e.marks_obtained
)
AND EXISTS
(
    SELECT 1
    FROM Students s3
    INNER JOIN Enrollments e3
        ON s3.student_id = e3.student_id
    WHERE s3.department = s.department
    GROUP BY s3.department
    HAVING COUNT(*) > 1
);

-- =========================================================
-- Task 1.4(h)
-- Window Functions
-- ROW_NUMBER()
-- RANK()
-- DENSE_RANK()
-- =========================================================

SELECT
    s.department,
    s.student_name,
    e.marks_obtained,

    ROW_NUMBER() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS row_number,

    RANK() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS rank,

    DENSE_RANK() OVER
    (
        PARTITION BY s.department
        ORDER BY e.marks_obtained DESC
    ) AS dense_rank

FROM Students s
INNER JOIN Enrollments e
ON s.student_id = e.student_id

ORDER BY
    s.department,
    e.marks_obtained DESC;
-- =========================================================
-- Task 1.5 - Transactions and Isolation
-- =========================================================

-- =========================================================
-- Task 1.5(a)
-- Transfer a student from CS101 to CS404.
-- Roll back the transaction if the insert fails.
-- =========================================================

BEGIN;

DELETE FROM Enrollments
WHERE student_id = 1
  AND course_code = 'CS101';

SAVEPOINT transfer_point;

INSERT INTO Enrollments
(student_id, course_code, enrollment_year, marks_obtained)
VALUES
(1, 'CS404', 2025, NULL);

-- If the INSERT fails, roll back to the savepoint.
-- (Example: due to a foreign key violation if CS404 does not exist.)

-- ROLLBACK TO SAVEPOINT transfer_point;

COMMIT;

-- If an unrecoverable error occurs, execute:
-- ROLLBACK;


-- =========================================================
-- Task 1.5(b)
-- Concurrency Anomaly
-- =========================================================

/*
Scenario:
Transaction T1 reads a student's marks_obtained.
Transaction T2 updates that value and commits.
Transaction T1 reads the same row again and gets a different value.

Concurrency Anomaly:
Non-Repeatable Read

Minimum Isolation Level that prevents it:
REPEATABLE READ
*/


-- =========================================================
-- Task 1.5(c)
-- Course Capacity Concurrency Problem
-- =========================================================

/*
Scenario:
Two concurrent transactions both read the same enrollment count.
Both conclude that the course has room available.
Both insert a new enrollment.
The course capacity is exceeded.

Concurrency Anomaly:
Write Skew (under snapshot-based MVCC systems) or an overbooking
scenario caused by concurrent transactions making decisions on the
same data.

Isolation Level that prevents it:
SERIALIZABLE
*/


-- =========================================================
-- Task 1.5(d)
-- MVCC Explanation
-- =========================================================

/*
Multi-Version Concurrency Control (MVCC)

A reporting transaction starts and reads a student's marks.

Another transaction updates the student's marks and commits.

If the reporting transaction re-reads the same row while operating
under REPEATABLE READ, it continues to see the original value from
its transaction snapshot.

Reason:
MVCC provides each transaction with a consistent snapshot of the
database as it existed when the transaction began. Changes committed
after the snapshot are not visible to that transaction.

Isolation Level that guarantees this behaviour:
REPEATABLE READ

Trade-off:
REPEATABLE READ provides greater consistency than READ COMMITTED,
but it may increase resource usage and reduce concurrency because
older row versions must be retained while long-running transactions
remain active.
*/

-- =========================================================
-- End of queries.sql
-- =========================================================
