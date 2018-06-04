package lab1;
import java.util.Stack;
import java.util.NoSuchElementException;

public class Queue<E> extends Stack<E>{
    private  Stack<E> stk;
    public Queue( ){
        stk = new Stack<E>();
    }
    void data_transport()
    {
        int ssize = super.size() - 1;
        while (ssize >= 0) {
            stk.push(super.get(ssize));
            ssize--;
        }
        super.removeAllElements();
    }
    public boolean add(E e) throws IllegalStateException, ClassCastException,
            NullPointerException, IllegalArgumentException {
        super.push(e);
        return true;
    }
    public boolean offer(E e) throws ClassCastException, NullPointerException,
            IllegalArgumentException{
        try {
            super.push(e);
        }
        catch (ClassCastException ex1) {
            throw ex1;
        }
        catch (NullPointerException ex2) {
            throw ex2;
        }
        catch (IllegalArgumentException ex3) {
            throw ex3;
        }
        catch (Exception ex){
            return false;
        }
        return true;
    }
    public E remove( ) throws NoSuchElementException{
        if (stk.isEmpty() && super.isEmpty())
            throw new NoSuchElementException();
        if (stk.isEmpty()) {
            data_transport();
        }
        return stk.pop();
    }
    public E poll( ) {
        if (stk.isEmpty() && super.isEmpty())
            return null;
        if (stk.isEmpty()) {
            data_transport();
        }
        return stk.pop();
    }
    public E peek ( ) {
        if (stk.isEmpty() && super.isEmpty())
            return null;
        if (stk.isEmpty())
            return super.get(0);
        else
            return stk.peek();
    }
    public E element( ) throws NoSuchElementException {
        if (stk.isEmpty() && super.isEmpty()) {
            throw new NoSuchElementException();
        }
        if (stk.isEmpty()) {
            return super.get(0);
        }
        return stk.peek();
    }

    public static void main(String[] args) {
        Queue<Integer> x = new Queue<Integer>();
        System.out.println("ok1");
        x.add(1);
        System.out.println("ok2");
        x.add(2);
        System.out.println("ok3");
        x.add(3);
        System.out.println("ok4");
        Integer y = x.poll();
        System.out.println(y);
        y = x.poll();
        System.out.println(y);
        y = x.poll();
        System.out.println(y);
    }
}

