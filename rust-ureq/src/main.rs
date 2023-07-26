fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = ureq::builder().no_delay(true).build();

    for i in 1..=1000 {
        let response = client
            .get("http://127.0.0.1:8000/get")
            .set("connection", "keep-alive")
            .call()?
            .into_string()?;
        println!("{i} {response}");
    }

    Ok(())
}
