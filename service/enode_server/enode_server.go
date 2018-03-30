package main

import (
    "fmt"
    "net/http"
    "net"
    "log"
    "flag"
    "strings"
    "os"
    "bufio"
    "runtime"
    "regexp"
)

func getMyIpAddr() (string) {
    var ipAddrStr string
    var ifaceStr string
    if runtime.GOOS == "darwin" {
        ifaceStr = "en0"
    } else {
        ifaceStr = "eth0"
    }
    iface, err := net.InterfaceByName(ifaceStr)

    if err != nil {
        log.Fatal(err)
    }

    addrs, err := iface.Addrs()
    if err != nil {
        log.Fatal(err)
        return ""
    }

    for _, addr := range addrs {
        if err != nil {
            log.Fatal(err)
        } else {
            addrStr := addr.String()
            re := regexp.MustCompile("([0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+)")
            match := re.FindStringSubmatch(addrStr)
            if match != nil {
                ipAddrStr = match[1]
            }
        }
    }

    return ipAddrStr
}

func getENode(w http.ResponseWriter, r *http.Request) {
    bootnodeLog := os.Getenv("ETH_LOG_DIR") + "/bootnode.log"
    file, err := os.Open(bootnodeLog)
    
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    var enodeUrl string
    for scanner.Scan() {
        line := scanner.Text()
        idx := strings.Index(line, "self=enode")
        if idx > -1 {
            runes := []rune(line)
            enodeUrl = string(runes[idx+5:])
        }
    }

    if err := scanner.Err(); err != nil {
        log.Fatal(err)
    }

    if enodeUrl != "" {
        myIpAddr := getMyIpAddr()
        enodeUrlWithIp := strings.Replace(enodeUrl, "[::]", myIpAddr, 1)
        fmt.Fprintf(w, enodeUrlWithIp)
    } else {
        fmt.Fprintf(w, "No enode URL")
    }
}

func main() {

    port := flag.Int("port", 80, "port number of listen on")
    flag.Parse()
    http.HandleFunc("/", getENode) // set router
    err := http.ListenAndServe(fmt.Sprintf(":%d", *port), nil) // set listen port
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
