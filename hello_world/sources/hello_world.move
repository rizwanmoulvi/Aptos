module Domains {

    resource TLD {
        owner: address;
    }

    resource Record {
        owner: address;
        value: vector<u8>;
    }

    resource Domain {
        owner: address;
        name: vector<u8>;
    }

    public fun valid_name(name: vector<u8): bool {
        let len = Vector.len(name);
        return len >= 3 && len <= 10;
    }

    public fun register_name(name: vector<u8, 10>, tld: address) {
        let name_str = Vector.to_hex(name);
        let tld_str = Vector.to_hex(move(tld));
        let full_domain = Vector.concat(name_str, Vector.concat(".", tld_str));
        let sender: address;
        sender = get_txn_sender();
        let sender_str = Vector.to_hex(sender);

        if !valid_name(name) {
            0x0;
        } else {
            let full_name = Vector.concat(name_str, full_domain);
            let name_exists: bool;
            name_exists = exists<Domain>(move(sender_str));
            if name_exists {
                0x0;
            } else {
                move_to<Domain>(move(sender_str), Domain{owner: sender, name: full_name});
            }
        }
    }

    public fun set_record(name: vector<u8, 10>, value: vector<u8>) {
        let sender: address;
        sender = get_txn_sender();
        let sender_str = Vector.to_hex(sender);

        let name_exists: bool;
        name_exists = exists<Domain>(move(sender_str));

        if name_exists {
            let domain: &mut Domain;
            domain = borrow_global_mut<Domain>(move(sender_str));
            if domain.owner == sender {
                let record_exists: bool;
                record_exists = exists<Record>(move(sender_str));
                if record_exists {
                    0x0;
                } else {
                    move_to<Record>(move(sender_str), Record{owner: sender, value: value});
                }
            } else {
                0x0;
            }
        } else {
            0x0;
        }
    }

    public fun get_record(name: vector<u8, 10): vector<u8> {
        let sender: address;
        sender = get_txn_sender();
        let sender_str = Vector.to_hex(sender);
        let record_exists: bool;
        record_exists = exists<Record>(move(sender_str);

        if record_exists {
            let record: &mut Record;
            record = borrow_global_mut<Record>(move(sender_str));
            if record.owner == sender {
                return record.value;
            } else {
                Vector<u8>::empty();
            }
        } else {
            Vector<u8>::empty();
        }
    }
}
