fn main() -> Result<(), Box<dyn std::error::Error>> {
    let response: String = ureq::get("http://127.0.0.1:8000/get")
        .call()?
        .into_string()?;
    println!("{response}");
    Ok(())
}
