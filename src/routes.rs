use crate::model::keyvalue::KeyValueJson;
use crate::model::project::ProjectJson;
use crate::plumbing::keyvalue::add_keyvalue;
use crate::plumbing::project::add_project;
use crate::Pool;

use actix_web::http::StatusCode;
use actix_web::{web, Error, HttpResponse};
use anyhow::Result;

pub async fn home() -> Result<HttpResponse, Error> {
    Ok(HttpResponse::build(StatusCode::OK)
        .content_type("text/html; charset=utf-8")
        .body(include_str!("../templates/index.html")))
}

pub async fn project_add(
    pool: web::Data<Pool>,
    item: web::Json<ProjectJson>,
) -> Result<HttpResponse, Error> {
    Ok(web::block(move || add_project(pool, item))
        .await
        .map(|project| HttpResponse::Created().json(project))
        .map_err(|_| HttpResponse::InternalServerError())?)
}

pub async fn keyvalue_add(
    pool: web::Data<Pool>,
    item: web::Json<KeyValueJson>,
) -> Result<HttpResponse, Error> {
    Ok(web::block(move || add_keyvalue(pool, item))
        .await
        .map(|project| HttpResponse::Created().json(project))
        .map_err(|_| HttpResponse::InternalServerError())?)
}

#[cfg(test)]
mod tests {
    use super::*;
    use actix_web::http;
    use actix_web::test;
    use actix_web::{http::header, web, App};
    use diesel::r2d2::ConnectionManager;
    use diesel::SqliteConnection;

    #[actix_rt::test]
    async fn test_index() {
        let database_url = "foo.db";
        let database_pool = Pool::builder()
            .build(ConnectionManager::<SqliteConnection>::new(database_url))
            .unwrap();
        let mut app = test::init_service(
            App::new()
                .data(database_pool.clone())
                .route("/homessss", web::post().to(home)),
        )
        .await;
        let ti = r#"{ "sk": "mykey", "identiifier": "identiifier2", "human_name" : "sdfsdfsf" }"#;

        //let req = test::TestRequest::post().uri("/").to_request();
        let req = test::TestRequest::post()
            .header(header::CONTENT_TYPE, "application/json")
            .set_payload(ti)
            .uri("/homessss")
            .to_request();
        let resp = test::call_service(&mut app, req).await;
        //assert!(resp.status().is_client_error());

        assert_eq!(resp.status(), http::StatusCode::OK);
    }
    /*
    #[actix_rt::test]
    async fn test_index_post() {
        let database_url = "foo.db";
        let database_pool = Pool::builder()
            .build(ConnectionManager::<SqliteConnection>::new(database_url))
            .unwrap();
        let mut app = test::init_service(
            App::new()
                .data(database_pool.clone())
                .route("/addlink", web::post().to(add_link_noop)),
        )
        .await;
        let ti = r#"{ "sk": "mykey", "identiifier": "identiifier2", "human_name" : "sdfsdfsf" }"#
            .as_bytes();
        //let req = test::TestRequest::post().uri("/").to_request();
        let req = test::TestRequest::post()
            .header(header::CONTENT_TYPE, "application/json")
            .set_payload(ti)
            .uri("/addlink")
            .to_request();
        let resp = test::call_service(&mut app, req).await;
        //assert!(resp.status().is_client_error());

        assert_eq!(resp.status(), 201);
    }
    */
}