struct UserInfoKeys {

    // CodingUserInfoKey(rawValue:) only returns nil for empty strings
    public static let decodingContext = CodingUserInfoKey(rawValue: "decodingContext")!

}
