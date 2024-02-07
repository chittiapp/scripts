install() {

    sudo cp ./flysecret.sh /usr/local/bin/
    sudo cp ./flylog.sh /usr/local/bin/
    chmod +x /usr/local/bin/flysecret.sh
    chmod +x /usr/local/bin/flylog.sh
    echo -e '#fly.io\n' >>~/.bashrc
    echo -e 'alias flysecret="/usr/local/bin/flysecret.sh"\n' >>~/.bashrc
    echo -e 'alias flylog="/usr/local/bin/flylog.sh"\n' >>~/.bashrc
    echo "Installation completed Restart the terminal to use flysecret and flylog commands."

}

install
