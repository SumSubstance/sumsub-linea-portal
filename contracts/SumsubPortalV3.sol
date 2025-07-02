// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {AbstractPortalV2} from "@verax-attestation-registry/verax-contracts/contracts/abstracts/AbstractPortalV2.sol";
import {AttestationPayload} from "@verax-attestation-registry/verax-contracts/contracts/types/Structs.sol";
/**
 * @title Sumsub Portal for Proof of Humanity
 * @author Sumsub Team
 * @notice This contract attests Sumsub proof of humanity verification on Linea Sepolia testnet/mainnet with multiple schema ID support
 * @dev This contract inherits from AbstractPortalV2 and provides Sumsub-specific attestation logic
 */
contract SumsubPortalV3 is AbstractPortalV2, Ownable, EIP712 {
    address public signerAddress;
    mapping(bytes32 => bool) public schemaIds; // Mapping to store valid schema IDs
    bytes32[] private schemaIdList; // Array to track schema IDs for retrieval
    string private constant SIGNING_DOMAIN = "VerifySumsub";
    string private constant SIGNATURE_VERSION = "1";
    error InvalidSchema();
    error InvalidSubject();
    error InvalidSignature();
    error SchemaIdAlreadyExists();
    error SchemaIdNotFound();
    error InvalidInput();
    error NotImplemented();
    event SignerAddressUpdated(address indexed oldSigner, address indexed newSigner);
    event SchemaIdAdded(bytes32 indexed schemaId);
    event SchemaIdRemoved(bytes32 indexed schemaId);
    event SchemaIdRemovalWarning(bytes32 indexed schemaId, string message);
    constructor(
        address[] memory modules,
        address router,
        address _signerAddress,
        bytes32 _initialSchemaId
    ) AbstractPortalV2(modules, router) Ownable(msg.sender) EIP712(SIGNING_DOMAIN, SIGNATURE_VERSION) {
        signerAddress = _signerAddress;
        schemaIds[_initialSchemaId] = true;
        schemaIdList.push(_initialSchemaId);
        emit SchemaIdAdded(_initialSchemaId);
    }
    /**
     * @inheritdoc AbstractPortalV2
     * @dev Checks if the subject is a valid address, the value sent is sufficient,
     *      the schema ID is valid, and the payload is correctly signed
     */
    function _onAttest(
        AttestationPayload memory attestationPayload,
        bytes[] memory validationPayloads,
        uint256 value
    ) internal view override {
        if (attestationPayload.subject.length != 20) revert InvalidSubject();
        address subject = address(uint160(bytes20(attestationPayload.subject)));
        if (subject == address(0)) revert InvalidSubject();
        if (!schemaIds[attestationPayload.schemaId]) revert InvalidSchema();
        if (!verifySignature(validationPayloads[0], attestationPayload.attestationData, subject, attestationPayload.schemaId)) revert InvalidSignature();
    }
    /**
     * @notice Validates a replacement attestation payload
     * @param attestationPayload The new attestation payload
     */
    function _onReplace(
        bytes32 /*attestationId*/,
        AttestationPayload memory attestationPayload,
        address /*attester*/,
        uint256 /*value*/
    ) internal view override {
        if (msg.sender != owner()) revert OnlyPortalOwner();
        if (!schemaIds[attestationPayload.schemaId]) revert InvalidSchema();
    }
    /**
     * @notice Validates bulk replacement attestation payloads
     * @param attestationsPayloads The new attestation payloads
     */
    function _onBulkReplace(
        bytes32[] memory /*attestationIds*/,
        AttestationPayload[] memory attestationsPayloads,
        bytes[][] memory /*validationPayloads*/
    ) internal view override {
        if (msg.sender != owner()) revert OnlyPortalOwner();
        for (uint256 i = 0; i < attestationsPayloads.length; i++) {
            if (!schemaIds[attestationsPayloads[i].schemaId]) revert InvalidSchema();
        }
    }
    /**
     * @inheritdoc AbstractPortalV2
     * @dev This function is not implemented
     */
    function _onBulkAttest(
        AttestationPayload[] memory /*attestationsPayloads*/,
        bytes[][] memory /*validationPayloads*/
    ) internal pure override {
        revert NotImplemented();
    }
    /**
     * @inheritdoc AbstractPortalV2
     * @dev Only the Portal owner can revoke attestations
     */
    function _onRevoke(bytes32 /*attestationId*/) internal view override {
        if (msg.sender != owner()) revert OnlyPortalOwner();
    }
    /**
     * @inheritdoc AbstractPortalV2
     * @dev Only the Portal owner can revoke attestations
     */
    function _onBulkRevoke(bytes32[] memory /*attestationIds*/) internal view override {
        if (msg.sender != owner()) revert OnlyPortalOwner();
    }
    /**
     * @notice Verify the signature for the attestation
     * @param signature The signature to verify
     * @param attestationData The raw attestation data
     * @param subject The subject address
     * @param schemaId The schema ID for the attestation
     * @return True if the signature is valid
     */
    function verifySignature(bytes memory signature, bytes memory attestationData, address subject, bytes32 schemaId) internal view returns (bool) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(keccak256("Sumsub(bytes32 attestationData,address subject,bytes32 schemaId)"), keccak256(attestationData), subject, schemaId))
        );
        address signer = ECDSA.recover(digest, signature);
        return signer == signerAddress;
    }
    /**
     * @notice Sets the signer address
     * @param _signerAddress The new signer address
     * @dev Emits a SignerAddressUpdated event
     */
    function setSignerAddress(address _signerAddress) public onlyOwner {
        if (_signerAddress == address(0)) revert InvalidInput();
        address oldSigner = signerAddress;
        signerAddress = _signerAddress;
        emit SignerAddressUpdated(oldSigner, _signerAddress);
    }
    /**
     * @notice Adds a new schema ID
     * @param _schemaId The schema ID to add
     * @dev Emits a SchemaIdAdded event
     */
    function addSchemaId(bytes32 _schemaId) public onlyOwner {
        if (schemaIds[_schemaId]) revert SchemaIdAlreadyExists();
        schemaIds[_schemaId] = true;
        schemaIdList.push(_schemaId);
        emit SchemaIdAdded(_schemaId);
    }
    /**
     * @notice Removes a schema ID
     * @param _schemaId The schema ID to remove
     * @dev Emits SchemaIdRemoved and SchemaIdRemovalWarning events
     */
    function removeSchemaId(bytes32 _schemaId) public onlyOwner {
        if (!schemaIds[_schemaId]) revert SchemaIdNotFound();
        schemaIds[_schemaId] = false;
        // Remove from schemaIdList
        for (uint256 i = 0; i < schemaIdList.length; i++) {
            if (schemaIdList[i] == _schemaId) {
                schemaIdList[i] = schemaIdList[schemaIdList.length - 1];
                schemaIdList.pop();
                break;
            }
        }
        emit SchemaIdRemoved(_schemaId);
    }
    /**
     * @notice Get all valid schema IDs
     * @return An array of valid schema IDs
     */
    function getSchemaIds() external view returns (bytes32[] memory) {
        return schemaIdList;
    }
    /**
     * @notice Gets the current signer address
     * @return The current signer address
     */
    function getSignerAddress() external view returns (address) {
        return signerAddress;
    }
}
