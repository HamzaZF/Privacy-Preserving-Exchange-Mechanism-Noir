# Project Name

This project implements three Zero-Knowledge Proofs (ZKPs) related to the paper titled "Privacy-Preserving Exchange Mechanism and its Application to Energy Market". These ZKPs have been implemented using Noir, a Domain Specific Language (DSL) tailored for SNARK proving systems. Noir is designed to leverage any ACIR-compatible proving system, providing simplicity and familiarity in its syntax, based on Rust.

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)
- [Contact](#contact)

## Installing Noir

Nargo serves as a comprehensive toolset for Noir, offering functionalities ranging from project initialization to compilation, execution, proving, verification, testing, and even Solidity contract generation.

To install Noir using noirup, follow these simple steps:

1. Open a terminal on your machine.
2. Run the following command:

```bash
curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
```

3. Close the terminal and open a new one.
4. Run:

```bash
noirup
```

That's it! You should now have the latest version of Noir installed and ready to use. Confirm the installation by checking the version with nargo --version.

You also have the flexibility to install nightly builds, specific versions, or branches. Refer to the noirup repository for further details.

## Usage

To execute a Noir proof, navigate to a specific proof directory and run:

```bash
nargo prove
```

This command will trigger the proving process, generating a .proof file within a proofs directory.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Contact

If you have any questions or suggestions regarding this implementation, feel free to reach out to me at [hamza.zarfaoui@telecom-paris.fr].
