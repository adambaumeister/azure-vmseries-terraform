from configure_panorama import connect, gen_bootstrap, show_bootstrap, bootstrap, gen_init_cfgs, parse_args
import os

if __name__ == '__main__':
    """
    Run a set of integration tests if we're called from the command line
    You must configure environment varibles that map to a real instance of Panorama.
        WINDOWS
            set P_HOSTNAME=1.1.1.1
            set P_USERNAME=admin
            set P_PASSWORD=whatever
        NIX
            export P_HOSTNAME=1.1.1.1
            export P_USERNAME=admin
            export P_PASSWORD=whatever
    """
    query = {
        "panorama_ip": os.getenv("P_HOSTNAME"),
        "username": os.getenv("P_USERNAME"),
        "password": os.getenv("P_PASSWORD")
    }
    query = parse_args(query)
    r = gen_init_cfgs(query, "012345678910")
    if query["panorama_ip"]:
        p = connect(query)
        show_bootstrap(p)
        key = gen_bootstrap(p, "24")
        assert(key)

