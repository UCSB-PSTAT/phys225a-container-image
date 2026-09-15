c.ServerProxy.servers = {
    "streamlit": {
        "command": [
            "conda", "run", "-n", "hep",
            "findingz-ui",
            "--server.port=8501",
            "--server.enableCORS=false",
            "--server.headless=true"
        ],
        "port": 8501,
        "absolute_url": False,
        "timeout" : 3600,
        "launcher_entry": {
                "enabled": True,
                "icon_path": "/opt/streamlit-mark-color.svg",
                "title": "Streamlit UI",
        },
        "new_browser_tab": False
    }
}
