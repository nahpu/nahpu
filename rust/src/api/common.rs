//! Common API calls

use std::time::SystemTime;

/// Check if Rust is working
pub fn check_rust() -> String {
    let msg = format!(
        "Rust API is working. Sanity check: {}",
        SystemTime::now()
            .duration_since(SystemTime::UNIX_EPOCH)
            .unwrap_or_default()
            .as_secs()
    );
    msg
}

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}
