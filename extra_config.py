c.ServerProxy.servers = {
    "streamlit_ui": {
        "command" : ["conda", "run", "-n", "hep", "findingz-ui --server.port=8501"],
        "port" : 8501,
        "absolute_url": False,
        "timeout" : 3600,
        "launcher_entry": {
                "enabled": True,
                "icon_path": "/opt/streamlit-mark-color.svg",
                "title": "Streamlit UI",
                "path_info": "streamlit/"
        },
        "new_browser_tab": False
    }
}
