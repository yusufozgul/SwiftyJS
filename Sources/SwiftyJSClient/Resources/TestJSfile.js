var lastUser = null;

function createUser() {
    let user = {
        id: 10,
        name: "Yusuf",
        score:5.1,
    }

    lastUser = user;
    return user;
}

async function createAsyncUser() {
    let user = {
        id: 10,
        name: "Async user",
        score:5.1,
    }

    lastUser = user;
    return user;
}

async function createAsyncUserWithoutReturn() {
    let user = {
    id: 10,
    name: "Async user without return",
    score:5.1,
    }

    lastUser = user;
}
