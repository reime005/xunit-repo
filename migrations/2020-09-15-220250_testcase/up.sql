PRAGMA foreign_keys = ON;
/*
 Typically map 1:1 to a git repo
 */
CREATE TABLE project (
    id INTEGER PRIMARY KEY NOT NULL,
    sk CHARACTER(32) UNIQUE NOT NULL,
    -- identiifier of a project
    identiifier VARCHAR UNIQUE NOT NULL,
    -- HUman name for project
    human_name VARCHAR NOT NULL
);
/*
 Each project may have many enviroment for example a branch and an architecture.
 */
CREATE TABLE enviroment (
    id INTEGER PRIMARY KEY NOT NULL,
    sk CHARACTER(32) NOT NULL,
    /*Hash of all key values*/
    hash_keyvalue CHARACTER(32) UNIQUE NOT NULL,
    /* Expire date,
     None for a branch, with a date for a Pull Request */
    best_before INT,
    fk_project INTEGER NOT NULL,
    FOREIGN KEY (fk_project) REFERENCES project (id) ON DELETE CASCADE ON UPDATE NO ACTION
);
/*
 Key value pairs make up the compoenents of an enviroment
 */
CREATE TABLE keyvalue (
    id INTEGER PRIMARY KEY NOT NULL,
    key TEXT NOT NULL,
    value TEXT NOT NULL,
    UNIQUE (key, value) ON CONFLICT ABORT
);
/*
 Enviroments are defined by the keyvalue that make them up.
 */
CREATE TABLE bind_enviroment_keyvalue (
    id INTEGER PRIMARY KEY NOT NULL,
    fk_enviroment INTEGER NOT NULL,
    fk_keyvalue INTEGER NOT NULL,
    FOREIGN KEY (fk_enviroment) REFERENCES enviroment (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_keyvalue) REFERENCES keyvalue (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_enviroment, fk_keyvalue) ON CONFLICT ABORT
);
/*
 Allows grouping of many enviroments in a single run
 this maybe shared across enviroments but not projects
 */
CREATE TABLE run_identifier (
    id INTEGER PRIMARY KEY NOT NULL,
    sk CHARACTER(32) UNIQUE NOT NULL,
    /* Client identifier
     for example GIT_COMMIT + CI/CD BUILD_NUMBER
     */
    client_identifier CHARACTER(32) NOT NULL,
    created BigInt NOT NULL,
    fk_project INTEGER NOT NULL,
    FOREIGN KEY (fk_project) REFERENCES project (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (sk, fk_project) ON CONFLICT ABORT,
    UNIQUE (client_identifier, fk_project) ON CONFLICT ABORT
);
/*
 test_run Happens in an enviroments for a run identifier
 */
CREATE TABLE test_run (
    id INTEGER PRIMARY KEY NOT NULL,
    sk CHARACTER(32) UNIQUE NOT NULL,
    created BigInt NOT NULL,
    fk_run_identifier INTEGER NOT NULL,
    fk_enviroment INTEGER NOT NULL,
    FOREIGN KEY (fk_enviroment) REFERENCES enviroment (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_run_identifier) REFERENCES run_identifier (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_run_identifier, fk_enviroment) ON CONFLICT ABORT
);
/*
 test_file have one or more test files
 */
CREATE TABLE test_file (
    id INTEGER PRIMARY KEY NOT NULL,
    directory VARCHAR NOT NULL,
    file_name VARCHAR NOT NULL,
    UNIQUE (directory, file_name) ON CONFLICT ABORT
);
/*
 test_run have one or more test files
 */
CREATE TABLE test_file_run (
    id INTEGER PRIMARY KEY NOT NULL,
    sk CHARACTER(32) UNIQUE NOT NULL,
    fk_test_file INTEGER NOT NULL,
    fk_test_run INTEGER NOT NULL,
    FOREIGN KEY (fk_test_file) REFERENCES test_file (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_test_file, fk_test_run) ON CONFLICT ABORT
);
/*
 Many tests have the same name and classname
 */
CREATE TABLE test_case (
    id INTEGER PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    classname TEXT NOT NULL,
    UNIQUE (name, classname) ON CONFLICT ABORT
);
/*
 Allows grouping of many enviroments in a single run
 this maybe shared across enviroments but not projects
 */
CREATE TABLE test_case_pass (
    id INTEGER PRIMARY KEY NOT NULL,
    fk_test_case INTEGER NOT NULL,
    /* Number of seconds to run */
    time REAL,
    fk_test_file_run INTEGER NOT NULL,
    FOREIGN KEY (fk_test_case) REFERENCES test_case (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_test_file_run) REFERENCES test_file_run (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_test_case, fk_test_file_run) ON CONFLICT ABORT
);
/*
 Allows grouping of many enviroments in a single run
 this maybe shared across enviroments but not projects
 */
CREATE TABLE test_case_skipped (
    id INTEGER PRIMARY KEY NOT NULL,
    fk_test_case INTEGER NOT NULL,
    /* Number of seconds to run */
    time REAL,
    skipped_message TEXT,
    fk_test_file_run INTEGER NOT NULL,
    FOREIGN KEY (fk_test_case) REFERENCES test_case (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_test_file_run) REFERENCES test_file_run (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_test_case, fk_test_file_run) ON CONFLICT ABORT
);
/*
 Allows grouping of many enviroments in a single run
 this maybe shared across enviroments but not projects
 */
CREATE TABLE test_case_error (
    id INTEGER PRIMARY KEY NOT NULL,
    fk_test_case INTEGER NOT NULL,
    /* Number of seconds to run */
    time REAL,
    error_message TEXT,
    error_type TEXT,
    error_description TEXT,
    system_out TEXT,
    system_err TEXT,
    fk_test_file_run INTEGER NOT NULL,
    FOREIGN KEY (fk_test_case) REFERENCES test_case (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_test_file_run) REFERENCES test_file_run (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_test_case, fk_test_file_run) ON CONFLICT ABORT
);
/*
 Allows grouping of many enviroments in a single run
 this maybe shared across enviroments but not projects
 */
CREATE TABLE test_case_failure (
    id INTEGER PRIMARY KEY NOT NULL,
    fk_test_case INTEGER NOT NULL,
    /* Number of seconds to run */
    time REAL,
    failure_message TEXT,
    failure_type TEXT,
    failure_description TEXT,
    system_out TEXT,
    system_err TEXT,
    fk_test_file_run INTEGER NOT NULL,
    FOREIGN KEY (fk_test_case) REFERENCES test_case (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (fk_test_file_run) REFERENCES test_file_run (id) ON DELETE CASCADE ON UPDATE NO ACTION,
    UNIQUE (fk_test_case, fk_test_file_run) ON CONFLICT ABORT
);