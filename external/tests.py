from configure_panorama import *
import os
import subprocess

TEST_QUERY = {
    "panorama_ip": "10.100.100.10",
    "username": "testadmin",
    "password": "testpasswprd",
    "panorama_private_ip": "10.10.10.10",
    "storage_account_name": "test",
    "storage_account_key": "test",
    "inbound_storage_share_name": "test-ib",
    "outbound_storage_share_name": "test-ob",
    "key_lifetime": "8760",
    "output_dir": os.path.join("test", "output", "path")
}

def test_upload_license_success(mocker):
    # Mock the subprocess return object
    mock_complete_process = subprocess.CompletedProcess([], returncode=0, stdout="Example")

    mocker.patch('subprocess.run', return_value=mock_complete_process)
    r = upload_license("test_path", "key", "sanname", "sharename")
    assert len(r) == 1

def test_upload_license_failed(mocker):
    # Same as test_upload_license_success but mock a failed command
    # Function should return SystemError
    mock_complete_process = subprocess.CompletedProcess([], returncode=0, stdout="Whoopsie", stderr="Broken!")

    mocker.patch('subprocess.run', return_value=mock_complete_process)
    try:
        r = upload_license("test_path", "key", "sanname", "sharename")
        raise ValueError("Test should have returned SystemError.")
    except SystemError as e:
        assert e

def test_upload_licenses(mocker):
    mocker.patch("configure_panorama.upload_license", return_value=True)
    mocker.patch("os.path.isdir", return_value=True)
    assert upload_licenses(TEST_QUERY)

def test_upload_licenses_nodir(mocker):
    # Test hadnling is correct when missing license directory
    mocker.patch("configure_panorama.upload_license", return_value=True)
    mocker.patch("os.path.isdir", return_value=False)
    assert not upload_licenses(TEST_QUERY)

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
        "password": os.getenv("P_PASSWORD"),
        "panorama_private_ip": "10.10.10.10",
        "storage_account_name": "test",
        "storage_account_key": "test",
        "inbound_storage_share_name": "test-ib",
        "outbound_storage_share_name": "test-ob",
        "key_lifetime": "8760",
        "output_dir": os.getcwd()
    }
    query = parse_args(query)
    r = gen_inbound_init_cfgs(query, "012345678910")
    r = upload_licenses(query)
