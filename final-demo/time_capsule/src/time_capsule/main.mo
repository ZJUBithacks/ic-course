import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Map "mo:base/HashMap";
import TrieSet "mo:base/TrieSet";
import Iter "mo:base/Iter";
import Result "mo:base/Result";

actor TimeCapsule {
    type Capsule = {
        id: Nat;
        creator: Principal;
        content: Text;
        to: ?Principal; // null means anyone can open it
        sealedTime: Time.Time;
        unlockTime: Time.Time;
    };

    type CapsuleResponse = {
        id: Nat;
        creator: Principal;
        content: ?Text;
        to: ?Principal;
        sealedTime: Time.Time;
        unlockTime: Time.Time;
    };

    type CreateCapsuleArgs = {
        content: Text;
        to: ?Principal;
        unlockTime: Time.Time;
    };

    type CreateCapsuleResponse = Result.Result<Nat, Text>;
    type GetCapsuleResponse = Result.Result<CapsuleResponse, Text>;

    private stable var capsules_upgrade: [Capsule] = [];
    private var capsules = Buffer.Buffer<Capsule>(1);
    // private stable var user_entries: [(Principal, Nat)] = [];
    // private var user_capsules = Map.fromIter<Principal, TrieSet.Set<Nat>>(user_entries, 1, Principal.equal, Principal.hash);
    // private stable var public_capsules = Trie.Set<Nat>.empty();

    private func _transform(capsule: Capsule): CapsuleResponse {
        let content = if (Time.now() > capsule.unlockTime) {
            // time pass, open it
            ?capsule.content
        } else {
            null
        };
        {
            id = capsule.id;
            creator = capsule.creator;
            content = content;
            to = capsule.to;
            sealedTime = capsule.sealedTime;
            unlockTime = capsule.unlockTime;
        }
    };
 
    public shared(msg) func createCapsule(createCapsuleArgs: CreateCapsuleArgs) : async CreateCapsuleResponse  {
        if (Principal.isAnonymous(msg.caller)) {
            return #err("Anonymous user can not create time capsule");
        };

        if (createCapsuleArgs.unlockTime <= Time.now()) {
            return #err("Unlock time must be set in the future");
        };

        let capsule_id = capsules.size();
        let capsule: Capsule = {
            id = capsule_id;
            creator = msg.caller;
            content = createCapsuleArgs.content;
            to =  createCapsuleArgs.to;
            sealedTime = Time.now();
            unlockTime = createCapsuleArgs.unlockTime;
        };
        capsules.add(capsule);

        #ok(capsule_id)
    };

    public query func getAllCapsules(): async [CapsuleResponse] {
        Array.map(
            capsules.toArray(),
            func (capsule: Capsule) : CapsuleResponse {
                {
                    id = capsule.id;
                    creator = capsule.creator;
                    content = null;
                    to = capsule.to;
                    sealedTime = capsule.sealedTime;
                    unlockTime = capsule.unlockTime;
                }
            }
        )
    };

    // get capsules that caller can open
    public query(msg) func getUserCapsules(): async [CapsuleResponse] {
        Array.map(
            Array.filter(
                capsules.toArray(),
                func (capsule: Capsule) : Bool {
                    switch(capsule.to) {
                        case (null) { 
                            // public capsule, anyone can open
                            true
                        };
                        case (?to) {
                            to == msg.caller
                        };
                    };
                }
            ),
            func (capsule: Capsule) : CapsuleResponse {
                {
                    id = capsule.id;
                    creator = capsule.creator;
                    content = null;
                    to = capsule.to;
                    sealedTime = capsule.sealedTime;
                    unlockTime = capsule.unlockTime;
                }
            }
        )
    };

    public query(msg) func getCapsule(id: Nat) : async GetCapsuleResponse {
        let capsule = capsules.getOpt(id);
        switch (capsule) {
            case (null) {
                return #err("Capsule not exist");
            };
            case (?c) {
                switch(c.to) {
                    case (null) { };
                    case (?to) {
                        if (to != msg.caller) {
                            return #err("Receiver not match");
                        };
                    };
                };
                return #ok(_transform(c));
            };
        };
    };

    system func preupgrade() {
        capsules_upgrade := capsules.toArray();
        // user_entries := Iter.toArray(user_capsules.entries);
    };

    system func postupgrade() {
        capsules := Buffer.Buffer<Capsule>(capsules_upgrade.size());
        for (c in capsules_upgrade.vals()) {
            capsules.add(c);
        };
        capsules_upgrade := [];
        // user_entries := [];
    };
};
