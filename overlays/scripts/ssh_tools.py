# 1. add servers
# 2. connect to servers
# 3. transer files to servers

import json
import os
import argparse
import subprocess
from pathlib import Path

home_dir = str(Path.home())
base_dir = home_dir + "/.config/ssh_tools"
config_filename = base_dir + "/hosts.json"


def get_servers():
    servers = None
    with open(config_filename, "r") as config_file:
        servers = json.load(config_file)
    return servers


parser = argparse.ArgumentParser()
parser.add_argument(
    "-a",
    "--add_host",
    help="add new host info to the config file",
    action="store_true",
)
parser.add_argument("-n", "--name", help="specify the name of the host")
parser.add_argument(
    "-u", "--user", help="specify the user used to login into the new host"
)
parser.add_argument(
    "-adr", "--address", help="specify the ip or domain of the new host"
)
parser.add_argument(
    "-p", "--port", type=int, help="specify the port of the new host"
)
parser.add_argument(
    "-c",
    "--choose",
    help="specify the name of the host you want to connect to",
)
parser.add_argument(
    "-f", "--sshfs", action="store_true", help="mount remote filesystem"
)

args = parser.parse_args()

if args.add_host:
    if not os.path.isfile(config_filename):
        with open(config_filename, "w") as config_file:
            servers = {"hosts": []}
            servers["hosts"].append(
                {
                    "name": args.name,
                    "user": args.user,
                    "address": args.address,
                    "port": args.port,
                }
            )
            json.dump(servers, config_file, indent=4)
    else:
        servers = get_servers()
        for host in servers["hosts"]:
            if args.name == host["name"]:
                print("The name is already taken!")
                os.exit()
        servers["hosts"].append(
            {
                "name": args.name,
                "user": args.user,
                "address": args.address,
                "port": args.port,
            }
        )
        with open(config_filename, "w") as config_file:
            json.dump(servers, config_file, indent=4)
elif args.choose:
    try:
        servers = get_servers()
        for host in servers["hosts"]:
            if host["name"] == args.choose:
                subprocess.run(
                    [
                        "ssh",
                        "-p",
                        str(host["port"]),
                        host["user"] + "@" + host["address"],
                    ]
                )
                os.exit()
        print("No host with such name")
    except SystemExit:
        pass
    else:
        print("Error in reading config file")
elif args.sshfs:
    try:
        servers = get_servers()
        for i, host in enumerate(servers["hosts"]):
            print(
                "{}:{}===>{}@{}:{}".format(
                    i,
                    host["name"],
                    host["user"],
                    host["address"],
                    host["port"],
                )
            )
        choice = int(input("input the number before the host info:"))
        mount_point = "/tmp/sshfs/" + servers["hosts"][choice]["name"]
        os.makedirs(mount_point, exist_ok=True)
        subprocess.run(
            [
                "sshfs",
                "-p",
                str(servers["hosts"][choice]["port"]),
                servers["hosts"][choice]["user"]
                + "@"
                + servers["hosts"][choice]["address"]
                + ":/",
                mount_point,
                "-o",
                "Compression=no",
                "-o",
                "auto_cache,reconnect",
            ]
        )
    except Exception as err:
        print(err)
else:
    try:
        servers = get_servers()
        for i, host in enumerate(servers["hosts"]):
            print(
                "{}:{}===>{}@{}:{}".format(
                    i,
                    host["name"],
                    host["user"],
                    host["address"],
                    host["port"],
                )
            )
        choice = int(input("input the number before the host info:"))
        subprocess.run(
            [
                "ssh",
                "-p",
                str(servers["hosts"][choice]["port"]),
                servers["hosts"][choice]["user"]
                + "@"
                + servers["hosts"][choice]["address"],
            ]
        )
    except SystemExit:
        pass
    else:
        print("Error in reading config file")
