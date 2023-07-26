use std::{
    convert::Infallible,
    net::{Ipv4Addr, SocketAddr},
};

use hyper::{
    service::{make_service_fn, service_fn},
    Body, Response, Server,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?
        .block_on(async {
            let addr = SocketAddr::from((Ipv4Addr::LOCALHOST, 8000));
            let make_service = make_service_fn(|_conn| async {
                Ok::<_, Infallible>(service_fn(|_req| async move {
                    Ok::<_, Infallible>(Response::new(Body::from("Rust Bits!\n")))
                }))
            });

            Server::bind(&addr)
                .tcp_nodelay(true)
                .serve(make_service)
                .await
                .map_err(Into::into)
        })
}
