use hyper::{body::Buf, client::Client};
use std::io::{stdout, Write};

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let uri = "http://127.0.0.1:8000/get".parse()?;
    let response = client.get(uri).await?;
    let mut body = hyper::body::aggregate(response.into_body()).await?;

    let mut stdout = stdout().lock();
    loop {
        let chunk = body.chunk();
        if chunk.is_empty() {
            break;
        }

        let n_read = stdout.write(chunk)?;
        body.advance(n_read);
    }
    stdout.flush()?;

    Ok(())
}
