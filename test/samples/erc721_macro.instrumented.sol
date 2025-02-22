/// This file is auto-generated by Scribble and shouldn't be edited directly.
/// Use --disarm prior to make any changes.
pragma solidity 0.8.12;

///  @title ERC721 token receiver interface
///  @dev Interface for any contract that wants to support safeTransfers
///  from ERC721 asset contracts.
interface IERC721Receiver {
    ///  @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
    ///  by `operator` from `from`, this function is called.
    ///  It must return its Solidity selector to confirm the token transfer.
    ///  If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
    ///  The selector can be obtained in Solidity with `IERC721.onERC721Received.selector`.
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

/// Utility contract holding a stack counter
contract __scribble_ReentrancyUtils {
    event AssertionFailed(string message);

    event AssertionFailedData(int eventId, bytes encodingData);

    bool __scribble_out_of_contract = true;
}

///  @dev Implementation of https://eips.ethereum.org/EIPS/eip-721[ERC721] Non-Fungible Token Standard, including
///  the Metadata extension, but not including the Enumerable extension, which is available separately as
///  {ERC721Enumerable}.
///  #macro erc721();
contract ERC721 is __scribble_ReentrancyUtils {
    event Transfer(address from, address to, uint256 tokenId);

    event Approval(address owner, address operator, uint256 tokenId);

    event ApprovalForAll(address owner, address operator, bool approved);

    struct vars2 {
        address old_0;
    }

    struct vars4 {
        address old_1;
        address old_2;
        bool old_3;
        address old_4;
    }

    struct vars5 {
        address old_5;
        address old_6;
        bool old_7;
        address old_8;
    }

    struct vars6 {
        address old_9;
        address old_10;
        bool old_11;
        address old_12;
    }

    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    ///  @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function balanceOf(address owner) virtual public returns (uint256 RET_0) {
        RET_0 = _original_ERC721_balanceOf(owner);
        unchecked {
            if (!(owner != address(0))) {
                emit AssertionFailed("1: NFTs cannot be owned by the 0 address");
                assert(false);
            }
        }
    }

    function _original_ERC721_balanceOf(address owner) private view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) virtual public returns (address RET_0) {
        RET_0 = _original_ERC721_ownerOf(tokenId);
        unchecked {
            if (!(RET_0 != address(0))) {
                emit AssertionFailed("2: NFTs cannot be owned by the 0 address");
                assert(false);
            }
            if (!(_original_ERC721_balanceOf(RET_0) > 0)) {
                emit AssertionFailed("3: ownerOf() should not contradict balanceOf");
                assert(false);
            }
        }
    }

    function _original_ERC721_ownerOf(uint256 tokenId) private view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    ///  @dev See {IERC721Metadata-name}.
    function name() virtual public view returns (string memory) {
        return _name;
    }

    ///  @dev See {IERC721Metadata-symbol}.
    function symbol() virtual public view returns (string memory) {
        return _symbol;
    }

    ///  @dev See {IERC721Metadata-tokenURI}.
    function tokenURI(uint256 tokenId) virtual public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = _baseURI();
        return "DUMMY";
    }

    ///  @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
    ///  token will be the concatenation of the `baseURI` and the `tokenId`. Empty
    ///  by default, can be overridden in child contracts.
    function _baseURI() virtual internal view returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) virtual public {
        vars2 memory _v;
        unchecked {
            _v.old_0 = _original_ERC721_ownerOf(tokenId);
        }
        _original_ERC721_approve(to, tokenId);
        unchecked {
            if (!((msg.sender == _original_ERC721_ownerOf(tokenId)) || isApprovedForAll(_original_ERC721_ownerOf(tokenId), msg.sender))) {
                emit AssertionFailed("16: Sender must be properly authorized to approve");
                assert(false);
            }
            if (!(getApproved(tokenId) == to)) {
                emit AssertionFailed("17: Approve works correctly");
                assert(false);
            }
            if (!(_original_ERC721_ownerOf(tokenId) == _v.old_0)) {
                emit AssertionFailed("18: Approve doesn't change ownership");
                assert(false);
            }
        }
    }

    function _original_ERC721_approve(address to, uint256 tokenId) private {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require((msg.sender == owner) || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }

    ///  @dev See {IERC721-getApproved}.
    function getApproved(uint256 tokenId) virtual public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) virtual public {
        _original_ERC721_setApprovalForAll(operator, approved);
        unchecked {
            if (!(approved == isApprovedForAll(msg.sender, operator))) {
                emit AssertionFailed("19: setApprovalForAll worked correctly");
                assert(false);
            }
        }
    }

    function _original_ERC721_setApprovalForAll(address operator, bool approved) private {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    ///  @dev See {IERC721-isApprovedForAll}.
    function isApprovedForAll(address owner, address operator) virtual public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) virtual public {
        vars4 memory _v;
        unchecked {
            _v.old_1 = _original_ERC721_ownerOf(tokenId);
            _v.old_2 = _original_ERC721_ownerOf(tokenId);
            _v.old_3 = isApprovedForAll(_original_ERC721_ownerOf(tokenId), msg.sender);
            _v.old_4 = getApproved(tokenId);
        }
        _original_ERC721_transferFrom(from, to, tokenId);
        unchecked {
            if (!(to != address(0))) {
                emit AssertionFailed("12: Cannot transfer to 0 address");
                assert(false);
            }
            if (!(_v.old_1 == from)) {
                emit AssertionFailed("13: from must be the current owner");
                assert(false);
            }
            if (!(((msg.sender == _v.old_2) || _v.old_3) || (_v.old_4 == msg.sender))) {
                emit AssertionFailed("14: Sender must be properly authorized to transfer");
                assert(false);
            }
            if (!(_original_ERC721_ownerOf(tokenId) == to)) {
                emit AssertionFailed("15: Transfer worked");
                assert(false);
            }
        }
    }

    function _original_ERC721_transferFrom(address from, address to, uint256 tokenId) private {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) virtual public {
        vars5 memory _v;
        unchecked {
            _v.old_5 = _original_ERC721_ownerOf(tokenId);
            _v.old_6 = _original_ERC721_ownerOf(tokenId);
            _v.old_7 = isApprovedForAll(_original_ERC721_ownerOf(tokenId), msg.sender);
            _v.old_8 = getApproved(tokenId);
        }
        _original_ERC721_safeTransferFrom(from, to, tokenId);
        unchecked {
            if (!(to != address(0))) {
                emit AssertionFailed("8: Cannot transfer to 0 address");
                assert(false);
            }
            if (!(_v.old_5 == from)) {
                emit AssertionFailed("9: from must be the current owner");
                assert(false);
            }
            if (!(((msg.sender == _v.old_6) || _v.old_7) || (_v.old_8 == msg.sender))) {
                emit AssertionFailed("10: Sender must be properly authorized to transfer");
                assert(false);
            }
            if (!(_original_ERC721_ownerOf(tokenId) == to)) {
                emit AssertionFailed("11: Transfer worked");
                assert(false);
            }
        }
    }

    function _original_ERC721_safeTransferFrom(address from, address to, uint256 tokenId) private {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) virtual public {
        vars6 memory _v;
        unchecked {
            _v.old_9 = _original_ERC721_ownerOf(tokenId);
            _v.old_10 = _original_ERC721_ownerOf(tokenId);
            _v.old_11 = isApprovedForAll(_original_ERC721_ownerOf(tokenId), msg.sender);
            _v.old_12 = getApproved(tokenId);
        }
        _original_ERC721_safeTransferFrom1(from, to, tokenId, _data);
        unchecked {
            if (!(to != address(0))) {
                emit AssertionFailed("4: Cannot transfer to 0 address");
                assert(false);
            }
            if (!(_v.old_9 == from)) {
                emit AssertionFailed("5: from must be the current owner");
                assert(false);
            }
            if (!(((msg.sender == _v.old_10) || _v.old_11) || (_v.old_12 == msg.sender))) {
                emit AssertionFailed("6: Sender must be properly authorized to transfer");
                assert(false);
            }
            if (!(_original_ERC721_ownerOf(tokenId) == to)) {
                emit AssertionFailed("7: Transfer worked");
                assert(false);
            }
        }
    }

    function _original_ERC721_safeTransferFrom1(address from, address to, uint256 tokenId, bytes memory _data) private {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    ///  @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
    ///  are aware of the ERC721 protocol to prevent tokens from being forever locked.
    ///  `_data` is additional data, it has no specified format and it is sent in call to `to`.
    ///  This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
    ///  implement alternative mechanisms to perform token transfer, such as signature-based.
    ///  Requirements:
    ///  - `from` cannot be the zero address.
    ///  - `to` cannot be the zero address.
    ///  - `tokenId` token must exist and be owned by `from`.
    ///  - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///  Emits a {Transfer} event.
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) virtual internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    ///  @dev Returns whether `tokenId` exists.
    ///  Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
    ///  Tokens start existing when they are minted (`_mint`),
    ///  and stop existing when they are burned (`_burn`).
    function _exists(uint256 tokenId) virtual internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    ///  @dev Returns whether `spender` is allowed to manage `tokenId`.
    ///  Requirements:
    ///  - `tokenId` must exist.
    function _isApprovedOrOwner(address spender, uint256 tokenId) virtual internal returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (((spender == owner) || (getApproved(tokenId) == spender)) || isApprovedForAll(owner, spender));
    }

    ///  @dev Safely mints `tokenId` and transfers it to `to`.
    ///  Requirements:
    ///  - `tokenId` must not exist.
    ///  - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
    ///  Emits a {Transfer} event.
    function _safeMint(address to, uint256 tokenId) virtual internal {
        _safeMint(to, tokenId, "");
    }

    ///  @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
    ///  forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
    function _safeMint(address to, uint256 tokenId, bytes memory _data) virtual internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    ///  @dev Mints `tokenId` and transfers it to `to`.
    ///  WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
    ///  Requirements:
    ///  - `tokenId` must not exist.
    ///  - `to` cannot be the zero address.
    ///  Emits a {Transfer} event.
    function _mint(address to, uint256 tokenId) virtual internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }

    ///  @dev Destroys `tokenId`.
    ///  The approval is cleared when the token is burned.
    ///  Requirements:
    ///  - `tokenId` must exist.
    ///  Emits a {Transfer} event.
    function _burn(uint256 tokenId) virtual internal {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        _approve(address(0), tokenId);
        _balances[owner] -= 1;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }

    ///  @dev Transfers `tokenId` from `from` to `to`.
    ///   As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
    ///  Requirements:
    ///  - `to` cannot be the zero address.
    ///  - `tokenId` token must be owned by `from`.
    ///  Emits a {Transfer} event.
    function _transfer(address from, address to, uint256 tokenId) virtual internal {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId);
        _approve(address(0), tokenId);
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }

    ///  @dev Approve `to` to operate on `tokenId`
    ///  Emits a {Approval} event.
    function _approve(address to, uint256 tokenId) virtual internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }

    ///  @dev Approve `operator` to operate on all of `owner` tokens
    ///  Emits a {ApprovalForAll} event.
    function _setApprovalForAll(address owner, address operator, bool approved) virtual internal {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    ///  @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
    ///  The call is not executed if the target address is not a contract.
    ///  @param from address representing the previous owner of the given token ID
    ///  @param to target address that will receive the tokens
    ///  @param tokenId uint256 ID of the token to be transferred
    ///  @param _data bytes optional data to send along with the call
    ///  @return bool whether the call correctly returned the expected magic value
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    ///  @dev Hook that is called before any token transfer. This includes minting
    ///  and burning.
    ///  Calling conditions:
    ///  - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
    ///  transferred to `to`.
    ///  - When `from` is zero, `tokenId` will be minted for `to`.
    ///  - When `to` is zero, ``from``'s `tokenId` will be burned.
    ///  - `from` and `to` are never both zero.
    ///  To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) virtual internal {}

    ///  @dev Hook that is called after any transfer of tokens. This includes
    ///  minting and burning.
    ///  Calling conditions:
    ///  - when `from` and `to` are both non-zero.
    ///  - `from` and `to` are never both zero.
    ///  To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
    function _afterTokenTransfer(address from, address to, uint256 tokenId) virtual internal {}
}
