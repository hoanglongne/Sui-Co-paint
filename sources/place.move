module sui_place::place {
    use std::vector;
    use sui::object::{UID, new};
    use sui::tx_context::{TxContext};
    use sui::transfer::share_object;
    use sui::dynamic_object_field;

    const EInvalidCoordinate: u64 = 0;
    const ESomeOtherError: u64 = 1;

    struct Place has key, store {
        id: UID
    }

    struct Quadrant has key, store {
        id: UID,
        quadrant_id: u8,
        board: vector<vector<u32>>
    }

    fun make_row(length: u64) : vector<u32> {
        let row = vector::empty<u32>();
        let i = 0;
        while (i < length) {
            vector::push_back(&mut row, 16_777_215);
            i = i + 1; 
        };
        row
    }

    fun make_quadrant_pixels(length: u64) : vector<vector<u32>> {
        let grid:vector<vector<u32>> = vector::empty<vector<u32>>();
        let i = 0;
        while (i < length) {
            vector::push_back(&mut grid, make_row(length));
            i = i + 1; 
        };
        grid
    }

    fun init(ctx: &mut TxContext) {
        let place = Place {
            id: new(ctx)
        };

        let i = 0;
        while (i < 4) {
            dynamic_object_field::add(
                &mut place.id,
                i,
                Quadrant {
                    id: new(ctx), 
                    quadrant_id: i,
                    board: make_quadrant_pixels(200)
                }
            );
            i = i + 1;
        };

        share_object(place)
    }

    public fun get_quadrant_id(x: u64, y: u64) : u8 {
        if (x < 200){
            if (y < 200){ 0 } else { 2 } 
        }  else { 
            if (y < 200){ 1 } else { 3 } 
        }
    }

    public fun set_pixel_at(place: &mut Place, x: u64, y: u64, color: u32) {
        assert!(x <400 && y < 400, EInvalidCoordinate);

        let quadrant_id = get_quadrant_id(x, y);
        let quadrant = dynamic_object_field::borrow_mut<u8, Quadrant>(&mut place.id, quadrant_id );
        let pixels: &mut u32 = vector::borrow_mut(vector::borrow_mut(&mut quadrant.board, x % 200), y % 200);
        *pixels = color;
    }

    // public fun get_quadrants(place: &Place) : vector<address> {
    //     // todo
    // }
}