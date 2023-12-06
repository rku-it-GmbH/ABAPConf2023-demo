@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package dependency hierarchy'
define hierarchy ZI_PackageDependencyHierarchy
  as parent child hierarchy(
    source ZI_PackageDependencies

    child to parent association _Parent
    //    start where
    //      ConsumerPackage is null
    siblings order by
      ConsumerPackage,
      ProviderInterface
    multiple parents allowed
    cycles breakup

  )
{
      @UI.hidden: true
  key ConsumerPackage,
      @UI.hidden: true
  key ProviderInterface,
      @UI.hidden: true
      ConsumerInterface,
      @UI.lineItem: [{ position: 1 }]
      ProviderPackage,
      @UI.hidden: true
      $node.node_id               as NodeID,
      @UI.hidden: true
      $node.parent_id             as ParentID,
      @UI.hidden: true
      $node.hierarchy_rank        as Rank,
      @UI.hidden: true
      $node.hierarchy_parent_rank as ParentRank,
      @UI.hidden: true
      $node.hierarchy_tree_size   as TreeSize,
      @UI.hidden: true
      $node.hierarchy_level       as TreeLevel,
      @UI.hidden: true
      $node.hierarchy_is_cycle    as IsCycle,
      @UI.hidden: true
      $node.hierarchy_is_orphan   as IsOrphan
}
