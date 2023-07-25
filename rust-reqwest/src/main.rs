fn main() -> Result<(), Box<dyn std::error::Error>> {
    tokio::runtime::Builder::new_current_thread()
        .enable_all()
        .build()?
        .block_on(async {
            for i in 1..=100 {
                let response = reqwest::get("http://127.0.0.1:8000/get")
                    .await?
                    .text()
                    .await?;
                println!("{i} {response}");
            }
            Ok(())
        })
}
