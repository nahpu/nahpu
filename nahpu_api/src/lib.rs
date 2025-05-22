pub mod archive;
pub mod databases;

pub fn test_lib() -> String {
    "Hello from NAHPU-API".to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        assert_eq!(test_lib(), "Hello from NAHPU-API");
    }
}
