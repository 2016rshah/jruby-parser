/*
 ***** BEGIN LICENSE BLOCK *****
 * Version: CPL 1.0/GPL 2.0/LGPL 2.1
 *
 * The contents of this file are subject to the Common Public
 * License Version 1.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.eclipse.org/legal/cpl-v10.html
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 *
 * Copyright (C) 2013 The JRuby team
 *
 * Alternatively, the contents of this file may be used under the terms of
 * either of the GNU General Public License Version 2 or later (the "GPL"),
 * or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
 * in which case the provisions of the GPL or the LGPL are applicable instead
 * of those above. If you wish to allow use of your version of this file only
 * under the terms of either the GPL or the LGPL, and not to allow others to
 * use your version of this file under the terms of the CPL, indicate your
 * decision by deleting the provisions above and replace them with the notice
 * and other provisions required by the GPL or the LGPL. If you do not delete
 * the provisions above, a recipient may use your version of this file under
 * the terms of any one of the CPL, the GPL or the LGPL.
 ***** END LICENSE BLOCK *****/

package org.jrubyparser.util.diff;

import org.jrubyparser.ast.Node;

import java.util.ArrayList;
import java.util.List;


/**
 * The SequenceMatcher class is used to produce a list of matching nodes.
 * @see NodeDiff
 */
public class SequenceMatcher
{
    protected IsJunk isJunk;
    protected Node newNode;
    protected Node oldNode;
    protected boolean hasIsJunk = true;
    ArrayList<Node> flatChildren;
    protected ArrayList<Node> matchingNodes;

    /**
     * Create a SequenceMatcher object without a function for sorting out junk.
     *
     * @param newNode
     * @param oldNode
     */
    public SequenceMatcher(Node newNode, Node oldNode) {
        this(newNode, oldNode, null);
    }

    /**
     * SequenceMatcher compares two nodes for matching nodes.
     *
     * isJunk is an object which implements the {@link IsJunk} interface and the
     * #hasIsJunk() method. hasIsJunk is a method which takes a Node and determines
     * whether or not it should be compared against the other node.
     *
     * We pass in two nodes. Later, we can use the #setSequence, #setSequenceOne and
     * #setSequenceTwo methods to change out one or both of the nodes and create a new set of
     * matches.
     *
     * @param isJunk
     * @param newNode
     * @param oldNode
     */
    public SequenceMatcher(Node newNode, Node oldNode, IsJunk isJunk) {
        if (isJunk == null) {
            hasIsJunk = false;
        } else {
            this.isJunk = isJunk;
        }

        flatChildren = new ArrayList<Node>();
        setSequences(newNode, oldNode);

    }

    public void setSequences(Node newNode, Node oldNode) {
        setSequenceOne(newNode);
        setSequenceTwo(oldNode);
    }

    public void setSequenceOne(Node newNode) {
        this.newNode = newNode;
    }

    public void setSequenceTwo(Node oldNode) {
        if (this.oldNode == oldNode) {
            return;
        } else {
            this.oldNode = oldNode;
            this.matchingNodes  = new ArrayList<Node>();
            flatChildren.clear();
            flattenChildren(oldNode);

        }
    }

    public Node getSequenceOne() {
        return this.newNode;
    }

    public Node getSequenceTwo() {
        return this.oldNode;
    }

    /**
     * We use this method to work through the tree of nodes building out a flat list
     * and simultaneously checking for "junk" against the user supplied #isJunk() method.
     *
     * @param node This is the oldNode passed in either when SM is created or by calling #setSequenceTwo().
     */
    public void flattenChildren(Node node) {
        List<Node> children = node.childNodes();


        if (children.isEmpty())
            return;

        if (hasIsJunk == true) {
            for (Node child: children) {
                if (!isJunk.checkJunk(child)) {
                    flatChildren.add(child);
                    flattenChildren(child);
                } else {
                    flattenChildren(child);
                }
            }

        } else {
            for (Node child: children) {
                flatChildren.add(child);
                flattenChildren(child);
            }

        }

    }

    public ArrayList<Node> getFlatChildren() {
        return flatChildren;
    }

    public int calcComplexity(Node node) {
        List<Node> children;
        int complexitySum = 1;
        if (!node.isLeaf()) {
            children = node.childNodes();
            for (Node child : children) {
                complexitySum = complexitySum + calcComplexity(child);
            }
        }
        return complexitySum;
    }


}

