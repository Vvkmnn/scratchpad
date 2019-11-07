#!/usr/bin/env python3


def criticalRouters(numRouters: int, numLinks: int, Links: [[int, int]]):
    class Router:
        def __init__(self, _id):
            self._id = _id
            self.links = []

        def addLink(self, router):
            self.links.append(router)

    def depthFirstSearch(rootNode, targetNode):
        """
        Depth first search based on Nodes with _id: Int field and links: Int[] to other nodes
        """
        visited = set()  # Set of visited nodes
        stack = []  # Stack of input nodes

        # Append root node first onto stack
        stack.append(rootNode)

        # While nodes in stack
        while len(stack) > 0:

            # Take first node off the stack
            top = stack.pop()

            # If top node (Router ID) is in visited set
            if top._id in visited:

                # Skip, already  in the path
                continue

            # If not visited and not the Target
            elif top._id != targetNode._id:

                # Remember visiting; add to set
                visited |= {top._id}  # True  # 1

                # Append its links to the stack to search
                stack += top.links

        # Return number of searched nodes until the targetNode from rootNode
        return len(visited)

    # Setup {{{
    # Convert IDs to Router Nodes
    routerList = [Router(i) for i in range(numLinks)]

    # For each router in links, add the corresponding links to each
    # Router node, in the internal incrementing list, so each node knows
    # which node it's connected to
    [
        (
            routerList[first_router].addLink(routerList[second_router]),
            routerList[second_router].addLink(routerList[first_router]),
        )
        for first_router, second_router in Links
    ]
    # }}}

    # Core {{{
    criticals = []

    print([router._id for router in routerList])

    # For every router from 0 to numRouters
    for i in range(numRouters):

        # If first node, make next node the root, otherwise path is
        # first node to first node, which is invalid; also, router is
        # also 0 -> [1,2,3,4,5,6] is same as 1 -> [0, 2, 3, 4, 5, 6]
        # rootNode = routerList[1] if i == 0 else routerList[0]

        # Could even try last element as root node if on first because
        # also 0 -> [1,2,3,4,5,6] is same as 6 -> [0, 1, 2, 3, 4, 5]
        # We are searching through the same map of elements for any paths
        # one less than the number of routers; essentially faster
        # than stepping through every node in the map
        rootNode, targetNode = (
            routerList[0] if i != 0 else routerList[-1],
            routerList[i],
        )

        # Check length of DFS to target router
        numberOfVisitedRouters = depthFirstSearch(rootNode, targetNode)
        # print(i, rootNode._id, targetNode._id, numberOfVisitedRouters)

        # If visited path is faster than stepping through every router,
        # DFS has found no special paths between two routers, so do nothing
        # But if path is shorter, there is a special link between
        # the root and the target, making it more critical if it goes down
        criticals.append(i) if numberOfVisitedRouters != numRouters - 1 else ()

    # }}}

    return criticals


numRouters = 7
numLinks = 7
Links = [[0, 1], [0, 2], [1, 3], [2, 3], [2, 5], [5, 6], [3, 4]]

print(criticalRouters(numRouters, numLinks, Links))
