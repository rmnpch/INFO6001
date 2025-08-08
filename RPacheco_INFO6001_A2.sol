// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract WasteReportSystem {
    struct Citizen {
        string name;
        bool registered;
    }

    enum Type {
        IllegalDumping,
        Littering,
        HazardousWaste
    }

    struct Report {
        string description;
        string latitude;
        string longitude;
        Type category;
        uint256 timestamp;
    }

    mapping(address => Report[]) public reports;

    mapping(address => Citizen) public citizens;

    event CitizenRegistered(address user, string name);
    event ReportSubmitted(
        address reporter,
        Type wasteType,
        string description,
        string latitude,
        string longitude,
        uint256 timestamp
    );

    function isFieldFilled(string memory field) internal pure returns (bool) {
        return bytes(field).length > 0;
    }

    function isValidCoordinate(string memory coord) internal pure returns (bool){
        bytes memory b = bytes(coord);
        if (b.length < 1 || b.length > 15) { // Flag as invalid input if coordinate is less than one or more than 15 characters
            return false;
        }

        bool isNumber = false; // This variablel will ultimately check if all the characters are numbers, except for `.`, `,`, and `-`
        bool hasDecimalSeparator = false; // Checks if input has one and only one decimal separator

        for (uint256 i = 0; i < b.length; i++) { // Loop though every character on the input string
            bytes1 char = b[i]; //Separate in individual bytes
            if (isDigit(char)) {
                isNumber = true;
            } else if (char == 0x2E || char == 0x2C) { // Checks for the decimal separator, both period or comma
                if (hasDecimalSeparator) return false; // Returns false if more than one is found
                hasDecimalSeparator = true;
            } else if (i == 0 && char == 0x2D) { // Allow leading '-', for negative coordinates
                continue;
            } else {
                return false; // Function returns false if any character does not match one of the conditions above
            }
        }
        return isNumber;
    }

    function isDigit(bytes1 char) internal pure returns (bool) {
        return char >= 0x30 && char <= 0x39; // Number between 0 and 9
    }

    function register(string memory _name) public {
        require(!citizens[msg.sender].registered, "Already registered!");
        require(isFieldFilled(_name), "Name cannot be empty");

        citizens[msg.sender] = Citizen({name: _name, registered: true});

        emit CitizenRegistered(msg.sender, _name);
    }

    function submitReport( uint256 _category, string memory _description, string memory _latitude, string memory _longitude ) public {
        require(_category < 3, "Invalid category");
        require(citizens[msg.sender].registered, "User not registered");
        require(isValidCoordinate(_latitude), "Invalid latitude");
        require(isValidCoordinate(_longitude), "Invalid longitude");

        reports[msg.sender].push(
            Report({
                category: Type(_category),
                latitude: _latitude,
                longitude: _longitude,
                description: _description,
                timestamp: block.timestamp
            })
        );

        emit ReportSubmitted(
            msg.sender,
            Type(_category),
            _description,
            _latitude,
            _longitude,
            block.timestamp
        );
    }

    function getReport(address _user) public view returns (Report[] memory) {
        return reports[_user];
    }
}
