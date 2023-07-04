use hyper::client::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();
    let uri = "http://127.0.0.1:8000/get".parse()?;
    let response = client.get(uri).await?;
    let body_bytes = hyper::body::to_bytes(response.into_body()).await?;
    println!("{}", String::from_utf8(body_bytes.to_vec())?);
    Ok(())
}
