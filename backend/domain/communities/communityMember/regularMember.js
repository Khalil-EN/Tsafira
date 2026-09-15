const CommunityMember = require("./communityMember");

class RegularMember extends CommunityMember {
  constructor(data) {
    super({ ...data, role: 'member' });
  }

}

module.exports = RegularMember;