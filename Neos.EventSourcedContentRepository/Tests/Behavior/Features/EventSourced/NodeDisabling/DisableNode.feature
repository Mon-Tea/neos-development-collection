@fixtures
Feature: Disable a node

  As a user of the CR I want to disable a node and expect its descendants to also be disabled.

  These are the base test cases for the NodeAggregateCommandHandler to block invalid commands.

  Background:
    Given I have no content dimensions
    And I have the following NodeTypes configuration:
    """
    'Neos.ContentRepository:Root': []
    'Neos.ContentRepository.Testing:Document': []
    """
    And the event RootWorkspaceWasCreated was published with payload:
      | Key                            | Value                                  |
      | workspaceName                  | "live"                                 |
      | workspaceTitle                 | "Live"                                 |
      | workspaceDescription           | "The live workspace"                   |
      | initiatingUserIdentifier       | "00000000-0000-0000-0000-000000000000" |
      | currentContentStreamIdentifier | "cs-identifier"                        |
    And the event RootNodeAggregateWithNodeWasCreated was published with payload:
      | Key                           | Value                                  |
      | contentStreamIdentifier       | "cs-identifier"                        |
      | nodeAggregateIdentifier       | "lady-eleonode-rootford"               |
      | nodeTypeName                  | "Neos.ContentRepository:Root"          |
      | visibleInDimensionSpacePoints | [{}]                                   |
      | initiatingUserIdentifier      | "00000000-0000-0000-0000-000000000000" |
      | nodeAggregateClassification   | "root"                                 |
    And the event NodeAggregateWithNodeWasCreated was published with payload:
      | Key                           | Value                                     |
      | contentStreamIdentifier       | "cs-identifier"                           |
      | nodeAggregateIdentifier       | "sir-david-nodenborough"                  |
      | nodeTypeName                  | "Neos.ContentRepository.Testing:Document" |
      | originDimensionSpacePoint     | {}                                        |
      | visibleInDimensionSpacePoints | [{}]                                      |
      | parentNodeAggregateIdentifier | "lady-eleonode-rootford"                  |
      | nodeName                      | "document"                                |
      | nodeAggregateClassification   | "regular"                                 |
    And the graph projection is fully up to date

  Scenario: Try to hide a node in a non-existing content stream
    When the command DisableNode is executed with payload and exceptions are caught:
      | Key                        | Value                    |
      | contentStreamIdentifier    | "i-do-not-exist"         |
      | nodeAggregateIdentifier    | "sir-david-nodenborough" |
      | coveredDimensionSpacePoint | {}                       |
      | nodeDisablingStrategy      | "scatter"                |
    Then the last command should have thrown an exception of type "ContentStreamDoesNotExistYet"

  Scenario: Try to hide a node in a non-existing dimension space point
    When the command DisableNode is executed with payload and exceptions are caught:
      | Key                        | Value                       |
      | contentStreamIdentifier    | "cs-identifier"             |
      | nodeAggregateIdentifier    | "sir-david-nodenborough"    |
      | coveredDimensionSpacePoint | {"undeclared": "undefined"} |
      | nodeDisablingStrategy      | "scatter"                   |
    Then the last command should have thrown an exception of type "DimensionSpacePointNotFound"

  Scenario: Try to hide a node in a non-existing node aggregate
    When the command DisableNode is executed with payload and exceptions are caught:
      | Key                        | Value            |
      | contentStreamIdentifier    | "cs-identifier"  |
      | nodeAggregateIdentifier    | "i-do-not-exist" |
      | coveredDimensionSpacePoint | {}               |
      | nodeDisablingStrategy      | "scatter"        |
    Then the last command should have thrown an exception of type "NodeAggregateCurrentlyDoesNotExist"
