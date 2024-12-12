-- 1.	Patients Table
/* This table stores personal and medical information about patients. */

CREATE TABLE Patients (
	PatientID SERIAL PRIMARY KEY,
	FirstName VARCHAR(100),
	LastName VARCHAR(100),
	DateOfBirth DATE,
	Gender VARCHAR(10) CHECK (GENDER IN('Male', 'Female', 'Other')),
	BloodType VARCHAR(3),
	Phone VARCHAR(20),
	Email VARCHAR(100),
	Address TEXT,
	EmergencyContact VARCHAR(100),
	MedicalHistory JSON,    --Medical history stored in JSON format for flexibility
	CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 2.	Doctors Table
/* This table stores information about doctors working in the hospital */

CREATE TABLE Doctors (
	DoctorID SERIAL PRIMARY KEY,	-- Automatically increments ID
	FirstName VARCHAR(100) NOT NULL,
	LastName VARCHAR(100) NOT NULL,
	Specialization VARCHAR(100) NOT NULL,
	Phone VARCHAR(20),
	Email VARCHAR(100),
	LicenseNumber VARCHAR(100) NOT NULL,
	Qualification TEXT, 			-- A field to store qualifications in text format
	Schedule JSONB, 				--Using JSONB type in PostgreSQL for efficient JSON operations
	CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 3.	Medical Records Table
/* This table stores records of diagnoses, treatments, medications, and procedures for each patient */

CREATE TABLE MedicalRecords (
	RecordID SERIAL PRIMARY KEY,	-- Automatically increments ID
	PatientID INT NOT NULL,
	DiagnosisCode VARCHAR(20),
	DiagnosisDescription TEXT,
	TreatmentDetails JSONB, 		-- Using JSNOB for better performance and querying
	Prescription JSONB,				-- Medications prescribed, stored as JSONB
	Procedure TEXT,
	TestResult JSONB,				-- Results from various diagnostic tests, stored as JSONB
	DoctorID INT NOT NULL,
	DateofVisit TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
	FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE SET NULL
);

-- 4. Appointments Table
/* This table tracks patient appointments with doctors */

CREATE TABLE Appointments (
    AppointmentID SERIAL PRIMARY KEY,  -- Automatically increments ID
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    AppointmentDate TIMESTAMP NOT NULL,  -- Using TIMESTAMP for date and time
    Status VARCHAR(20) CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),  -- Enum-like constraint
    ReasonForVisit TEXT,
    VisitType VARCHAR(20) CHECK (VisitType IN ('In-Person', 'Telemedicine')),  -- Enum-like constraint
    RoomNumber VARCHAR(20),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE SET NULL
);

-- 5. Billing Table
/* This table handles the financial transactions for hospital services */

CREATE TABLE Billing (
    BillID SERIAL PRIMARY KEY,  -- Automatically increments ID
    PatientID INT NOT NULL,
    TotalAmount DECIMAL(10, 2) NOT NULL,
    AmountPaid DECIMAL(10, 2) NOT NULL,
    AmountDue DECIMAL(10, 2) GENERATED ALWAYS AS (TotalAmount - AmountPaid) STORED, -- Calculated field
    BillingDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    InsuranceClaimStatus VARCHAR(20) CHECK (InsuranceClaimStatus IN ('Pending', 'Approved', 'Rejected')),  -- Enum-like constraint
    PaymentMethod VARCHAR(20) CHECK (PaymentMethod IN ('Cash', 'Credit Card', 'Insurance')),  -- Enum-like constraint
    PaymentStatus VARCHAR(20) CHECK (PaymentStatus IN ('Paid', 'Pending', 'Partially Paid')),  -- Enum-like constraint
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);

-- 6. Insurance Providers Table
/* This table stores information about insurance providers and related policies */

CREATE TABLE InsuranceProviders (
    InsuranceProviderID SERIAL PRIMARY KEY,  -- Automatically increments ID
    ProviderName VARCHAR(255) NOT NULL,
    PolicyType VARCHAR(100) NOT NULL,
    ContactInfo TEXT,
    PolicyDetails JSONB  -- Using JSONB for better performance with JSON data
);

-- 7. Suppliers Table
/* This table stores information about suppliers of medical items */

CREATE TABLE Suppliers (
    SupplierID SERIAL PRIMARY KEY,  -- Automatically increments ID
    SupplierName VARCHAR(255) NOT NULL,
    ContactInfo TEXT,
    Location VARCHAR(255),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Inventory Table
/* This table tracks medical supplies, medications, and equipment */

CREATE TABLE Inventory (
    ItemID SERIAL PRIMARY KEY,  -- Automatically increments ID
    ItemName VARCHAR(255) NOT NULL,
    Category VARCHAR(100),
    Quantity INT NOT NULL CHECK (Quantity >= 0),  -- Ensures Quantity cannot be negative
    ReorderLevel INT CHECK (ReorderLevel >= 0),  -- Ensures ReorderLevel cannot be negative
    ExpirationDate DATE,
    SupplierID INT,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),  -- Ensures Price cannot be negative
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE SET NULL
);

-- 9. Staff Table
/* This table stores information about non-medical staff (nurses, technicians, and administrators) */

CREATE TABLE Staff (
    StaffID SERIAL PRIMARY KEY,  -- Automatically increments ID
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Role VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20),
    Email VARCHAR(100),
    ShiftStartTime TIME,
    ShiftEndTime TIME,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. Laboratory Results Table
/* This table stores the test results for patients */

CREATE TABLE LaboratoryResults (
    TestID SERIAL PRIMARY KEY,  -- Automatically increments ID
    PatientID INT NOT NULL,
    TestType VARCHAR(100) NOT NULL,
    Results JSONB,  -- Using JSONB for better performance and querying
    TestDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    DoctorID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID) ON DELETE SET NULL
);


----------------------------------------------------------------------------------------------------------------------------------

/* Advanced Features for Optimization */

-- 11. Role-Based Access Control (RBAC)
/* Roles Table */

CREATE TABLE Roles (
    RoleID SERIAL PRIMARY KEY,          -- Unique identifier for each role
    RoleName VARCHAR(50) UNIQUE NOT NULL, -- Role name (e.g., Doctor, Nurse, Admin)
    Permissions JSONB                   -- Permissions assigned to the role stored in JSONB
);

/* Users Table */

CREATE TABLE Users (
    UserID SERIAL PRIMARY KEY,          -- Unique identifier for each user
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    RoleID INT NOT NULL,                -- Reference to Roles table
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash TEXT NOT NULL,         -- Hashed password for authentication
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(15),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (RoleID) REFERENCES Roles(RoleID) ON DELETE CASCADE
);

-- 12. Real-Time Notifications
/* Notifications Table */

CREATE TABLE Notifications (
    NotificationID SERIAL PRIMARY KEY,  -- Unique identifier for notifications
    UserID INT NOT NULL,                -- Reference to Users table
    Message TEXT NOT NULL,              -- Notification message
    SentAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Timestamp when the notification was sent
    Status VARCHAR(20) CHECK (Status IN ('Sent', 'Pending', 'Failed')), -- Notification status
    FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);


-- 13. Data Redundancy & Backup
/* While this is implemented at the infrastructure level, PostgreSQL supports replication using Streaming Replication, 
Logical Replication, and PgBackRest. Database schema changes do not directly address redundancy
but should support such setups by using normalized tables and avoiding circular dependencies. */

-- 14. Patient Portal Integration
/* PatientPortal Table */

CREATE TABLE PatientPortal (
    PortalID SERIAL PRIMARY KEY,        -- Unique identifier for the portal
    PatientID INT NOT NULL,             -- Reference to Patients table
    Username VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash TEXT NOT NULL,         -- Securely store hashed passwords
    LastLogin TIMESTAMP,
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID) ON DELETE CASCADE
);

-- 15. Data Analytics and Reporting
/* Analytics Queries : No dedicated table is required; analytics are derived from the database using queries.
However, a Reports Table can store generated reports. */

/* Reports Table */

CREATE TABLE Reports (
    ReportID SERIAL PRIMARY KEY,        -- Unique identifier for reports
    ReportName VARCHAR(100) NOT NULL,
    GeneratedBy INT NOT NULL,           -- Reference to Users table
    ReportData JSONB,                   -- Store report data as JSONB for flexibility
    GeneratedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (GeneratedBy) REFERENCES Users(UserID) ON DELETE CASCADE
);

-- 16. Integration with External Systems
/* IntegrationLogs Table */

CREATE TABLE IntegrationLogs (
    LogID SERIAL PRIMARY KEY,          -- Unique identifier for each integration log
    SystemName VARCHAR(100) NOT NULL,  -- Name of the external system
    RequestData JSONB,                 -- Data sent to the external system
    ResponseData JSONB,                -- Data received from the external system
    Status VARCHAR(20) CHECK (Status IN ('Success', 'Failure')),
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Audit Logs
/* AuditLogs Table */

CREATE TABLE AuditLogs (
    LogID SERIAL PRIMARY KEY,          -- Unique identifier for audit logs
    TableName VARCHAR(100) NOT NULL,   -- Name of the affected table
    Operation VARCHAR(20) CHECK (Operation IN ('INSERT', 'UPDATE', 'DELETE')), -- Type of operation
    RecordID INT NOT NULL,             -- ID of the affected record
    OldData JSONB,                     -- Data before the change
    NewData JSONB,                     -- Data after the change
    ChangedBy INT NOT NULL,            -- Reference to Users table
    Timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ChangedBy) REFERENCES Users(UserID) ON DELETE SET NULL
);































