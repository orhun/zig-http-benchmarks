use std::{
    io::{stdout, Write},
    time::Duration,
};

use hyper::{
    body::Buf,
    client::{Client, HttpConnector},
    Body, Request, Uri,
};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?
        .block_on(async {
            let client = Client::builder().build::<_, Body>({
                let mut conn = HttpConnector::new();
                conn.set_nodelay(true);
                conn.set_keepalive(Some(Duration::from_secs(30)));
                conn
            });
            let uri = "http://127.0.0.1:8000/get".parse::<Uri>()?;

            for i in 1..=1000 {
                let response = client
                    .request(
                        Request::get(&uri)
                            .header("connection", "keep-alive")
                            .body(Body::empty())?,
                    )
                    .await?;
                let body = hyper::body::aggregate(response.into_body()).await?;

                let mut stdout = stdout().lock();
                write!(&mut stdout, "{i} ")?;

                std::io::copy(&mut body.reader(), &mut stdout)?;

                stdout.write_all(b"\n")?;
                stdout.flush()?;
            }

            Ok(())
        })
}
