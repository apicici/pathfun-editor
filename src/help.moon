im = require "cimgui"

CollapsingHeader = im.CollapsingHeader_TreeNodeFlags
BulletTextWrapped = (text) ->
    im.Bullet()
    im.TextWrapped(text)

return ->
    if CollapsingHeader("General information")
        BulletTextWrapped("Saving is only allowed when changes are detected, in which case the menu bar will be highlighted.")
        BulletTextWrapped("Closed windows can be reopened from the View menu.")
        BulletTextWrapped("Some of the menu entries list keyboard shortcuts that can be used to easily access them.")

    if CollapsingHeader("Editing the polygon maps")
        if im.TreeNode_Str("Basic operations")
            BulletTextWrapped("Polygon maps can be added with the \"New polygon map\" button.")
            BulletTextWrapped("The polygon map to be edited can be selected by clicking on its name on the list.")
            BulletTextWrapped("To rename or delete a polygon map right-click on its name to bring up the context menu.")
            BulletTextWrapped("Click on the polygon map checkbox to hide/unhide it (checked means unhidden). Only named polygon maps can be hidden.")
            im.TreePop()

        if im.TreeNode_Str("Adding polygons")
            BulletTextWrapped("To add a new polygon to the selected polygon map left-click on an empty space to add a vertex. Repeat until all vertices have been created, then click on the first vertex to close the polygon.")
            BulletTextWrapped("While creating a new polygon you can right-click anywhere to remove the last added point.")
            BulletTextWrapped("When a polygon is added the polygon map is automatically updated to become the union of its polygons. Adding overlapping polygons is an easy way to build more complex polygon maps.")
            im.TreePop()

        if im.TreeNode_Str("Modifying polygons")
            BulletTextWrapped("Left-click on a vertex and drag the mouse to move a vertex around.")
            BulletTextWrapped("Right-click on a vertex to remove it.")
            BulletTextWrapped("Left-click on an edge to add a vertex at the cursor location. Hold the button down and drag to move the newly created point.")
            im.TreePop()

        if im.TreeNode_Str("Subtract mode")
            BulletTextWrapped("Use \"Edit->Subtract mode\" to enable.")
            BulletTextWrapped("While in subract mode, newly created polygons are subtracted from the polygon map instead of being added.")
            BulletTextWrapped("Subtract mode can be used to \"carve\" pieaces out or to create holes in the polygon map.")
            im.TreePop()

        if im.TreeNode_Str("Refresh & simplify")
            BulletTextWrapped("Refreshing a polygon map (\"Edit->Refresh polygon map\") can be used to take the union of the polygons in the polygon map if overlapping was created by moving vertices.")
            BulletTextWrapped("Use \"Edit->Simplify polygon map\" to automatically remove unneeded vertices. Note that this may remove points that are needed to connect different polygon maps, so use it carefully.")
            im.TreePop()

        if im.TreeNode_Str("Notes on multiple polygon maps")
            BulletTextWrapped("Two polygons belonging to different polygon maps are considered connected only if they share an edge. You may need to move some vertices if they were not perfectly aligned.")
            BulletTextWrapped("Pathfun expects all the vertices tp be external vertices. If joining two polygon maps makes a vertex internal the pathfinding algorithm won't work as expected.")
            BulletTextWrapped("You can switch to testing mode to check if the polygon maps are properly connected.")
            im.TreePop()

    if CollapsingHeader("Testing mode")
        BulletTextWrapped("Use \"Edit->Testing mode\" from the Navigation window to test pathfinding on the navigation area.")
        BulletTextWrapped("While in testing mode right-click on the navigation area to set the starting point. The target point follows the cursor.")
        BulletTextWrapped("Named polygon maps can also be hidden/unhidden in testing mode.")

    if CollapsingHeader("Camera")
        BulletTextWrapped("While holding space, click on the canvas and drag the mouse to move the camera.")
        BulletTextWrapped("Use the mouse wheel when the cursor is on the canvas to zoom in/out.")
        BulletTextWrapped("Use \"View->Reset View\" to reset panning and zoom.")
