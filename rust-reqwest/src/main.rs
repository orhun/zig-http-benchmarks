#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let response = reqwest::get("http://127.0.0.1:8000/get")
        .await?
        .text()
        .await?;
    println!("{}", response);
    Ok(())
}
