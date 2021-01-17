use crate::model::test_case_failure::{TestCaseFailure, TestCaseFailureNew};
use crate::Pool;
use actix_web::web;
use diesel::dsl::insert_into;
use diesel::prelude::*;
use diesel::RunQueryDsl;

pub fn add_test_case_failure(
    pool: web::Data<Pool>,
    filter_fk_test_file_run: i32,
    new_fk_test_case: i32,
    new_time: &Option<f32>,
    new_failure_message: &Option<String>,
    new_failure_type: &Option<String>,
    new_failure_description: &Option<String>,
    new_system_out: &Option<String>,
    new_system_err: &Option<String>,
) -> Result<TestCaseFailure, diesel::result::Error> {
    use crate::schema::test_case_failure::dsl::*;
    let db_connection = pool.get().unwrap();
    match test_case_failure
        .filter(fk_test_case.eq(new_fk_test_case))
        .filter(time.eq(new_time))
        .filter(failure_message.eq(new_failure_message))
        .filter(failure_type.eq(new_failure_type))
        .filter(failure_description.eq(new_failure_description))
        .filter(system_out.eq(new_system_out))
        .filter(system_err.eq(new_system_err))
        .filter(fk_test_file_run.eq(filter_fk_test_file_run))
        .first::<TestCaseFailure>(&db_connection)
    {
        Ok(result) => Ok(result),
        Err(_) => {
            let new_keyvalue = TestCaseFailureNew {
                fk_test_case: new_fk_test_case,
                time: new_time.clone(),
                failure_message: new_failure_message.as_deref(),
                failure_type: new_failure_type.as_deref(),
                failure_description: new_failure_description.as_deref(),
                system_out: new_system_out.as_deref(),
                system_err: new_system_err.as_deref(),
                fk_test_file_run: filter_fk_test_file_run,
            };

            insert_into(test_case_failure)
                .values(&new_keyvalue)
                .execute(&db_connection)
                .expect("Error saving new test case failure");

            let result = test_case_failure
                .order(id.desc())
                .first(&db_connection)
                .unwrap();
            Ok(result)
        }
    }
}