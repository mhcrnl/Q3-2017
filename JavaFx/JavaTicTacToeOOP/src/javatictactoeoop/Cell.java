/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javatictactoeoop;

/**
 *
 * @author mhcrnl
 */
public class Cell {
    
    Seed content;
    int row, cel;
    
    public Cell(int row, int col){
        this.row = row;
        this.cel = cel;
        clear();
    }
    
    public void clear(){
        content = Seed.EMPTY;
    }
    
    public void paint(){
        switch(content){
            case CROSS: System.out.print(" X "); break;
            case NOUGHT:System.out.print(" 0 "); break;
            case EMPTY: System.out.print("   ");break;
        }
    }
}
