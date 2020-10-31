""" Sets the local Fernet key in .env for running Airflow locally """
from os import path

from cryptography.fernet import Fernet


def main():
    """
    Script entrypoint
    """
    fernet_key = Fernet.generate_key()
    if path.exists(".env"):
        print(".env already exists, exiting script")
        return

    with open(".env", "w") as file:
        file_text = f"AIRFLOW__CORE__FERNET_KEY={fernet_key.decode()}"
        file.write(file_text)


if __name__ == "__main__":
    main()
