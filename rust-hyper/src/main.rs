use hyper::{body::Buf, client::Client, Uri};
use std::io::{stdout, Write};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?
        .block_on(async {
            let client = Client::new();
            let uri = "http://127.0.0.1:8000/get".parse::<Uri>()?;

            for i in 1..=100 {
                let response = client.get(uri.clone()).await?;
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
