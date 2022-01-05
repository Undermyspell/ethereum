// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract CuddleToys is ERC1155, Ownable {
    uint256 public constant PIEP_PIEP = 0;
    uint256 public constant MUEMMIE_WHITE_BIG = 1;
    uint256 public constant TOAST = 2;

    constructor() ERC1155("https://jmakgdvtdxls.usemoralis.com/{id}.json") {
        _mint(msg.sender, PIEP_PIEP, 1, "");
        _mint(msg.sender, MUEMMIE_WHITE_BIG, 1, "");
        _mint(msg.sender, TOAST, 1, "");
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        _mint(account, id, amount, "");
    }

    function burn(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyOwner {
        _burn(account, id, amount);
    }
}
