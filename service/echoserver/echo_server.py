import socket
import os

BUF_SIZE = 2048

def proxy_to_host(host, msg):
    connection = socket.create_connection((host, 1337))
    connection.send(msg)
    data = connection.recv(BUF_SIZE)
    return host + " (proxy) : " + data

def handle_connection(current_connection, address):
    hostname = socket.gethostname()
    data = current_connection.recv(BUF_SIZE)
    if data:
         if data.find("PROXY") == 0:
             # Format is PROXY:HOST:MSG
             data_ary = data.split(":")
             if len(data_ary) < 3:
                 data = "Message is malformed: %s" % data
             else:
                 host = data_ary[1]
                 msg = ":".join(data_ary[2:])
                 data = proxy_to_host(host, msg)
         try:
             current_connection.send(hostname + ' : ' + data)
             current_connection.shutdown(1)
             current_connection.close()
             print data
         except:
             pass

def listen():
    connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    connection.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    connection.bind(('0.0.0.0', 1337))
    connection.listen(10)
    while True:
        current_connection, address = connection.accept()
        newpid = os.fork()
        if newpid == 0:
            handle_connection(current_connection, address)
        else:
            print "Connection from %s handled by pid: %d" % (address, newpid)

if __name__ == "__main__":
    try:
        listen()
    except KeyboardInterrupt:
        pass
