-- This SQL script creates the necessary tables for the Datazine Facebook Insights database.
CREATE TABLE FansPerCity (
    Date TEXT,
    City TEXT,
    CountryCode TEXT,
    NumberOfFans INTEGER,
    FOREIGN KEY (CountryCode)
        REFERENCES PopStats (CountryCode)
);

CREATE TABLE FansPerCountry (
    Date TEXT,
    CountryCode TEXT,
    NumberOfFans INTEGER,
    FOREIGN KEY (CountryCode)
        REFERENCES PopStats (CountryCode)
);

CREATE TABLE FansPerGenderAge (
    Date TEXT,
    Gender TEXT,
    AgeGroup TEXT,
    NumberOfFans INTEGER
);

CREATE TABLE FansPerLanguage (
    Date TEXT,
    Language TEXT,
    CountryCode TEXT,
    NumberOfFans INTEGER,
    FOREIGN KEY (CountryCode)
        REFERENCES PopStats (CountryCode)
);

CREATE TABLE GlobalPage (
    Date TEXT,
    CountryCode TEXT,
    NewLikes INTEGER,
    DailyPostsReach INTEGER,
    DailyPostShares INTEGER,
    DailyPostActions INTEGER,
    DailyPostImpressions INTEGER,
    FOREIGN KEY (CountryCode)
        REFERENCES PopStats (CountryCode)
);

CREATE TABLE PopStats (
    CountryCode TEXT PRIMARY KEY,
    CountryName TEXT,
    Population INTEGER,
    AverageIncome INTEGER
);

CREATE TABLE PostInsights (
    CreatedTime TEXT,
    EngagedFans TEXT,
    Impressions INTEGER,
    NegativeFeedback INTEGER,
    NonViralImpressions INTEGER,
    NonViralReach INTEGER,
    PostActivity INTEGER,
    PostActivityUnique INTEGER,
    PostClicks INTEGER,
    UniquePostClicks INTEGER,
    PostReactionsAnger INTEGER,
    PostReactionsHaha INTEGER,
    PostReactionsLike INTEGER,
    PostReactionsLove INTEGER,
    PostReactionsSorry INTEGER,
    PostReactionsWow INTEGER,
    Reach INTEGER
);