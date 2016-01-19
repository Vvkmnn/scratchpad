# Commands
Top All-time Commands from [CommandlineFu.com](http://www.commandlinefu.com/commands/browse/sort-by-votes).


        sudo !!

Run the last command as root

        python -m SimpleHTTPServer

Serve current directory tree at `http://$HOSTNAME:8000/`

        ^foo^bar # replace 'foo' in last command with 'bar'

        echo Hello World
        ^Hello ^Bye

Runs previous command but replacing

        ctrl-x e
Rapidly invoke an editor to write a long, complex, or tricky command

        <space>command

Execute a command without saving it in the history

        'ALT+.' or '<ESC> .'

Place the argument of the most recent command on the shell

        reset

Salvage a borked terminal

        mount | column -t

currently mounted filesystems in nice layout

        echo "ls -l" | at midnight

Execute a command at a given time

        ssh -N -L2001:localhost:80 somemachine


start a tunnel from some machine's port 80 to your local post 2001

        curl ifconfig.me

Get your external IP address
curl ifconfig.me/ip -> IP Adress
curl ifconfig.me/host -> Remote Host
curl ifconfig.me/ua ->User Agent
curl ifconfig.me/port -> Port
thanks to http://ifconfig.me/


    dig +short txt <keyword>.wp.dg.cx
Query Wikipedia via console over DNS
Query Wikipedia by issuing a DNS query for a TXT record. The TXT record will also include a short URL to the complete corresponding Wikipedia entry.You can also write a little shell script like:
`$ cat wikisole.sh
#!/bin/sh
dig +short txt ${1}.wp.dg.cx
and run it like
./wikisole.sh unix`
were your first option ($1) will be used as search term.

        man ascii
Quick access to the ascii table.

        !!:gs/foo/bar

Runs previous command replacing foo by bar every time that foo appears
Very useful for rerunning a long command changing some arguments globally.
As opposed to ^foo^bar, which only replaces the first occurrence of foo, this one changes every occurrence.

        dd if=/dev/dsp | ssh -c arcfour -C username@host dd of=/dev/dsp

output your microphone to a remote computer's speaker
This will output the sound from your microphone port to the ssh target computer's speaker port. The sound quality is very bad, so you will hear a lot of hissing.

        sshfs name@server:/path/to/folder /path/to/mount/point

Mount folder/filesystem through SSH
Install SSHFS from http://fuse.sourceforge.net/sshfs.html
Will allow you to mount a folder security over a network.

        mount -t tmpfs tmpfs /mnt -o size=1024m

Mount a temporary ram partition
Makes a partition in ram which is useful if you need a temporary working space as read/write access is fast.
Be aware that anything saved in this partition will be gone after your computer is turned off.

        <ctrl+u> [...] <ctrl+y>

        # example
        vim /etc/fstab
        ## damn
        <ctrl+u> sudo <ctrl+y>
        ## like a boss.
        Example 2 :
        sudo vim /root/bin/
        ##uh... autocomplete doesn't work...
        <ctrl+u> sudo ls /root/bin
        ##ah! that's the name of the file!
        <ctrl+y> sudo vim /root/bin/ ##resume here! Thanks readline!
                    

type partial command, kill this command, check something you forgot, yank the command, resume typing.
Example :


        wget --random-wait -r -p -e robots=off -U mozilla http://www.example.com

        -p parameter #tells wget to include all files, including images.
        -e robots=off #you don't want wget to obey by the robots.txt file
        -U mozilla as your browsers identity.
        --random-wait #to let wget chose a random number of seconds to wait, avoid get into black list.
        --limit-rate=20k #limits the rate at which it downloads files.
        -b #continues wget after logging out.
        -o #$HOME/wget_log.txt logs the output

Download an entire website


        curl -u user:pass -d status="Tweeting from the shell" http://twitter.com/statuses/update.xml

Update twitter via curl

    ctrl-l

Clear the terminal screen

    ssh user@host cat /path/to/remotefile | diff /path/to/localfile -

Compare a remote file with a local file

    (cd /tmp && ls)

Jump to a directory, execute a command and jump back to current dir

    time read (ctrl-d to stop)

A very simple and useful stopwatch

    ssh -t reachable_host ssh unreachable_host

SSH connection through host in the middle
