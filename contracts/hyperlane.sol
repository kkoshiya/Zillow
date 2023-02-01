// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.13;

// ============ External Imports ============
import {Router} from "@hyperlane-xyz/core/contracts/Router.sol";
import {IMessageRecipient} from "@hyperlane-xyz/core/interfaces/IMessageRecipient.sol";
import {IOutbox} from "@hyperlane-xyz/core/interfaces/IOutbox.sol";

/*
 * @title The Hello World App
 * @dev You can use this simple app as a starting point for your own application.
 */
contract HelloWorld is Router {
    // A counter of how many messages have been sent from this contract.
    uint256 public sent;
    // A counter of how many messages have been received by this contract.
    uint256 public received;

    // Keyed by domain, a counter of how many messages that have been sent
    // from this contract to the domain.
    mapping(uint32 => uint256) public sentTo;
    // Keyed by domain, a counter of how many messages that have been received
    // by this contract from the domain.
    mapping(uint32 => uint256) public receivedFrom;

    // ============ Events ============
    event SentHelloWorld(
        uint32 indexed origin,
        uint32 indexed destination,
        string message
    );
    event ReceivedHelloWorld(
        uint32 indexed origin,
        uint32 indexed destination,
        bytes32 sender,
        string message
    );

    constructor(address _mailbox, address _interchainGasPaymaster) initializer {
        __HyperlaneConnectionClient_initialize(
            _mailbox,
            _interchainGasPaymaster
        );
    }

    // ============ External functions ============

    /**
     * @notice Sends a message to the _destinationDomain. Any msg.value is
     * used as interchain gas payment.
     * @param _destinationDomain The destination domain to send the message to.
     */
    function sendHelloWorld(uint32 _destinationDomain, string calldata _message)
        external
        payable
    {
        sent += 1;
        sentTo[_destinationDomain] += 1;
        // TODO: pay for gas in v2
        _dispatch(_destinationDomain, bytes(_message));
        emit SentHelloWorld(
            mailbox.localDomain(),
            _destinationDomain,
            _message
        );
    }

    // ============ Internal functions ============

    /**
     * @notice Handles a message from a remote router.
     * @dev Only called for messages sent from a remote router, as enforced by Router.sol.
     * @param _origin The domain of the origin of the message.
     * @param _sender The sender of the message.
     * @param _message The message body.
     */
    function _handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) internal override {
        received += 1;
        receivedFrom[_origin] += 1;
        emit ReceivedHelloWorld(
            _origin,
            mailbox.localDomain(),
            _sender,
            string(_message)
        );
    }
}















