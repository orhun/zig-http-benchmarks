fn main() -> Result<(), Box<dyn std::error::Error>> {
    for i in 1..=100 {
        let response: String = attohttpc::get("http://127.0.0.1:8000/get").send()?.text()?;
        println!("{i} {response}");
    }

    Ok(())
}
