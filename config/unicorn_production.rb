# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/path/to/weather-widget"  # REPLACE THIS!

# Unicorn PID file location
pid "/path/to/pids/unicorn.pid" # REPLACE THIS!

# Path to logs
stderr_path "/path/to/logs/unicorn.log" # REPLACE THIS!
stdout_path "/path/to/logs/unicorn.log" # REPLACE THIS!

# Unicorn socket
listen "/tmp/unicorn.[appname].sock" # REPLACE THIS!

# Number of processes
worker_processes 4

# Time-out
timeout 30
preload_app true
